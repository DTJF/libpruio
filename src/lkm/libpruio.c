/*! \file libpruio.c
\brief Source code of loadable kernel module (LKM)

When tainted to the kernel, the LKM checks for the TI-AM335x CPU and
the PRUSS version. In case of a missmatch or other problems, an error
message gets placed in the kernel log `dmesg`. In case of a match it

-# enables the PWMSS clocks (tbclk in CM)
-# creates a sysfs file for pinmuxing and tbclk settings

When untainted, it restores the original tbclk value.

The pinmuxing feature is save for Beaglebone double pins `P9_41` and
`P9_42`. Before the related CPU ball gets configured into the desired
mode, the other CPU ball gets set to the save `PRUIO_GPIO_IN` mode.

\since 0.6
*/

#include <linux/init.h>   // Macros used to mark up functions e.g., __init __exit
#include <linux/module.h> // Core header for loading LKMs into the kernel
#include <linux/kernel.h> // Contains types, macros, functions for the kernel
#include <linux/io.h>
#include <linux/err.h>
//#include <linux/errno.h>
#include <linux/platform_device.h>

MODULE_LICENSE("GPL");                        ///< The license type -- this affects runtime behavior
MODULE_AUTHOR("<Thomas.Freiherr@gmx.net>");   ///< The author -- visible when using modinfo
MODULE_DESCRIPTION("pinmuxing for libpruio"); ///< The description -- see modinfo
MODULE_VERSION("0.0");                        ///< The version of the module
//MODULE_SOFTDEP("pre: uio_pruss");   ///< soft dependency
MODULE_INFO(softdep, "pre: uio_pruss");       ///< soft dependency

static struct platform_device *pdev;
static   void __iomem *mem1, *mem2;
static unsigned int tbclk_org;


static unsigned char hex1(char t){
  return t <= 'F' ? (t >= 'A'  ? t - 'A' + 10
     : ((t >= '0' || t <= '9') ? t - '0'      : 255)
   ) : ((t >= 'a' || t <= 'f') ? t - 'a' + 10 : 255);
}

static ssize_t state_read(struct device *dev,
		struct device_attribute *attr, char *buf)
{
	return sprintf(buf, "tbclk=%u/%u (orig/curr)\n", tbclk_org, ioread16(mem1));
}

static ssize_t state_write(struct device *dev,
		struct device_attribute *attr, const char *buf, size_t count)
{
  unsigned offs, mode, i = 0;
  if(count < 4) {
    printk(KERN_ALERT "libpruioRtError: invalid setting\n");
  } else {
    while(i < count) {
      if (buf[i] < '0') {i++; continue;}

      offs = (hex1(buf[i]) << 4) + hex1(buf[i + 1]);
      if(offs > 128) {
        printk(KERN_ALERT "libpruioRtError: invalid ball# (%u)\n", offs);
      } else {
        mode = (hex1(buf[i + 2]) << 4) + hex1(buf[i + 3]);
        if(mode > 127) {
          printk(KERN_ALERT "libpruioRtError: invalid mode (%u)\n", mode);
        } else {
          switch(offs) {
            case 128: iowrite16(mode, mem1); break;
            case  89:
              iowrite16(0x2f, mem2 + 0x1a0);
              iowrite16(mode, mem2 + (offs << 2)); break;
            case 104:
              iowrite16(0x2f, mem2 + 0x164);
              iowrite16(mode, mem2 + (offs << 2)); break;
            case 106:
              iowrite16(0x2f, mem2 + 0x1b4);
              iowrite16(mode, mem2 + (offs << 2)); break;
            case 108:
              iowrite16(0x2f, mem2 + 0x1a8);
              iowrite16(mode, mem2 + (offs << 2)); break;
            default:
              iowrite16(mode, mem2 + (offs << 2));
          }
        }
      }
      i += 4;
    }
  }
	return count;
}

static DEVICE_ATTR(state, S_IWUSR | S_IRUGO | S_IWGRP | S_IRGRP, state_read, state_write);

static struct attribute *libpruio_attributes[] = {
	&dev_attr_state.attr,
	NULL
};

static const struct attribute_group libpruio_attr_group = {
	.attrs = libpruio_attributes,
};


static int fail(int N, char* Text, int Ret){
  if(N >= 5) sysfs_remove_group(&(&pdev->dev)->kobj, &libpruio_attr_group);
  if(N >= 4) platform_device_unregister(pdev);
  if(N >= 3) iounmap(mem2);
  if(N >= 2) iowrite16(tbclk_org, mem1);
  if(N >= 1) iounmap(mem1);
	if( Text ) printk(KERN_ALERT "libpruioInit: failed %s\n", Text);
  return Ret;
}

static int __init libpruio_init(void){
  mem1 = ioremap(0x44e10600uL, 0x10uL);
	if (!mem1)                          return fail(0, "ioremap CPU-ID", -ENOMEM);
  if ((ioread32(mem1) & 0xB94402EuL) != 0xB94402EuL)
                                     return fail(1, "ckecking CPU-ID", -ENODEV);
  if ((ioread32(mem1+4) & 0x10003uL) != 0x10003uL)
                               return fail(1, "ckecking CPU features", -ENODEV);
  iounmap(mem1);

  mem1 = ioremap(0x44e10664uL, 0x4uL);
	if (!mem1)                       return fail(0, "ioremap PWM_tbclk", -ENOMEM);
  tbclk_org = ioread16(mem1);
  iowrite16(tbclk_org | 0x7, mem1);

  mem2 = ioremap(0x44e10800uL, 0x200uL);
	if (!mem2)                       return fail(2, "ioremap CM pinmux", -ENOMEM);

  pdev = platform_device_register_simple("libpruio", -1, NULL, 0);
  if (IS_ERR(pdev))                    return fail(3, "register pdev",  PTR_ERR(pdev));

	if (sysfs_create_group(&(&pdev->dev)->kobj, &libpruio_attr_group))
	                                return fail(4, "create sysfs group", -ENODEV);
  return 0;
}

static void __exit libpruio_exit(void){
  fail(99, NULL, 0);
}

module_init(libpruio_init); //!< The constructor function
module_exit(libpruio_exit); //!< The destructor
