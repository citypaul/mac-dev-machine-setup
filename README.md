# Mac Dev Machine Setup

This repo will automatically setup a new mac so I don't have to go through the faff of installing and configuring everything each time I need to setup a new computer.

To run, it should just be a case of running `./install.sh`

## Alacritty Terminal

Here's how it looks running Zellij:

![alacritty theme](./docs/screenshots/alacritty-zellij.png)

## To setup the iterm theme

To setup the iterm theme, you will need to go to iterm -> Preferences and select "Profiles". The "Mac Dev Environment" profile should be there. Select, click "Other Actions" and click "Set as Default":

![iterm theme instructions](./docs/screenshots/choose-iterm-theme.png)

Look how lovely it looks:

![iterm theme](./docs/screenshots/iterm-theme-example.png)

And here is how Tmux looks:

![tmux theme](./docs/screenshots/tmux-theme-example.png)

## Understanding how GPG keys in Git work

[Refer to these docs](https://samuelsson.dev/sign-git-commits-on-github-with-gpg-in-macos/)

After running the `install.sh` script, you will need to manually run:

`gpgconf --kill gpg-agent`

And then do a commit. This will store the gpg key in the keychain so you don't have to keep adding the password every time.

## To setup personal .ssh key:

Run `./install-keys.sh`.

## Links

1. [Dotfiles](https://github.com/citypaul/.dotfiles)
