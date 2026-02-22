# dotfiles

Managed targets:
- tmux: `~/.tmux.conf`
- wezterm: `~/.config/wezterm/wezterm.lua`
- nvim: `~/.config/nvim`

## Safe check (no changes)

```bash
cd ~/.dotfiles
stow -nv tmux wezterm nvim
```

## Apply links

```bash
cd ~/.dotfiles
stow tmux wezterm nvim
```

## Remove links

```bash
cd ~/.dotfiles
stow -D tmux wezterm nvim
```
