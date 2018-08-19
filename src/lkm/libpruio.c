#include <linux/init.h>             // Macros used to mark up functions e.g., __init __exit
#include <linux/module.h>           // Core header for loading LKMs into the kernel
#include <linux/kernel.h>           // Contains types, macros, functions for the kernel
#include <linux/io.h>
#include <linux/err.h>
#include <linux/platform_device.h>

MODULE_LICENSE("GPL");              ///< The license type -- this affects runtime behavior
MODULE_AUTHOR("TJF");               ///< The author -- visible when you use modinfo
MODULE_DESCRIPTION("pinmuxing feature for libpruio");  ///< The description -- see modinfo
MODULE_VERSION("0.0");              ///< The version of the module
//MODULE_SOFTDEP("pre: uio_pruss");   ///< soft dependency

static struct platform_device *pdev;
static   void __iomem *mem0, *mem1, *mem2;
//static   void __iomem *mem2;
static unsigned int pruss_org, tbclk_org;


static unsigned char hex1(char t){
  return t <= 'F' ? (t >= 'A'  ? t - 'A' + 10
     : ((t >= '0' || t <= '9') ? t - '0'      : 255)
   ) : ((t >= 'a' || t <= 'f') ? t - 'a' + 10 : 255);
}

static ssize_t state_read(struct device *dev,
		struct device_attribute *attr, char *buf)
{
	return sprintf(buf, "tbclk=%u/%u (orig/curr)\nprclk=%u/%u (orig/curr)"
               , tbclk_org, ioread16(mem1), pruss_org, ioread32(mem0));
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

static DEVICE_ATTR(state, S_IWUSR | S_IRUGO, state_read, state_write);

static struct attribute *libpruio_attributes[] = {
	&dev_attr_state.attr,
	NULL
};

static const struct attribute_group libpruio_attr_group = {
	.attrs = libpruio_attributes,
};


static int fail(int N, char* Text, int Ret){
  //if(N >= 5) sysfs_remove_group(&(&pdev->dev)->kobj, &libpruio_attr_group);
  if(N >= 4) platform_device_unregister(pdev);
  if(N >= 3) iounmap(mem2);
  if(N >= 2) {iowrite16(tbclk_org, mem1); iounmap(mem1);}
  if(N >= 1) {iowrite32(pruss_org, mem0); iounmap(mem0);}
	if(Text) printk(KERN_ALERT "libpruioInitError: %s\n", Text);
  return Ret;
}

static int __init libpruio_init(void){
  int val;

  mem0 = ioremap(0x44e00c00uL, 0x10uL);
	if (!mem0) return fail(0, "ioremap pruss_clk", -ENODEV);

  pruss_org = ioread32(mem0);
  //iowrite32(pruss_org | 0x7, mem0);

  mem1 = ioremap(0x44e10664uL, 0x4uL);
	if (!mem1) return fail(1, "ioremap PWM_tbclk", -ENODEV);

  tbclk_org = ioread16(mem1);
  iowrite16(tbclk_org | 0x7, mem1);

  mem2 = ioremap(0x44e10800uL, 0x200uL);
	if (!mem2) return fail(2, "ioremap CM pinmux", -ENODEV);

  pdev = platform_device_register_simple("libpruio", -1, NULL, 0);
  if (IS_ERR(pdev)) fail(3, "register pdev", PTR_ERR(pdev));

	/* Register sysfs hooks */
	val = sysfs_create_group(&(&pdev->dev)->kobj, &libpruio_attr_group);
	if (val) fail(4, "create sysfs group", val);

  return 0;
}

static void __exit libpruio_exit(void){
  fail(3, NULL, 0);
}

module_init(libpruio_init);
module_exit(libpruio_exit);
