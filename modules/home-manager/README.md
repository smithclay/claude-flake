# Home-Manager Configuration

## Quick Fix for Missing home-manager Command

After running `home-manager switch`, the command itself may disappear. This is because home-manager needs to be installed separately from the packages it manages.

### Workaround Options:

1. **Use nix run (Recommended)**
   ```bash
   alias hm="nix run home-manager --"
   hm switch --flake /path/to/home-manager#clay
   ```

2. **Install home-manager to your profile**
   ```bash
   nix-env -iA nixpkgs.home-manager
   ```

3. **Use the flake directly**
   ```bash
   nix run github:nix-community/home-manager -- switch --flake .#clay
   ```

### Add Permanent Alias

Add this to your shell configuration:
```bash
alias hm="nix run home-manager --"
alias hms="nix run home-manager -- switch --flake ~/workspace/claude-flake/home-manager#clay"
```

Now you can just run `hms` to update your home configuration!