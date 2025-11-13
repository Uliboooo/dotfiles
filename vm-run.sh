qemu-system-aarch64 \
  -machine virt,accel=hvf \
  -cpu cortex-a72 \
  -smp 4 \
  -m 4G \
  -drive file=/Users/coyuki/Documents/Fedora-Server-43.aarch64.qcow2,if=virtio \
  -nographic \
  -netdev user,id=net0,hostfwd=tcp::2222-:22 \
  -device virtio-net-pci,netdev=net0

