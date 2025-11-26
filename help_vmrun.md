# vm run

## run without GUI (HeadLess)

```zsh
vmrun -T fusion start "Server.vmx" nogui
```

- `-T fusion`: host type

## Suspend

```zsh
vmrun -T fusion suspend "Server.vmx"
```

## Stop(Forse power off)

```zsh
vmrun -T fusion stop "Server.vmx" hard
```

## Stop (soft stop)

```zsh
vmrun -T fusion stop "Server.vmx" soft
```

