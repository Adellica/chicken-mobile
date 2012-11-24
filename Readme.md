
# chicken-mobile

A lightweight script to aid building chicken eggs and modules. In a very early development stage!

## One way to “install”

```bash
$ git clone <this repo>
$ ln -s <this repo>/chicken-mobile.scm ~/bin/chicken-mobile
```

## Trying it out

```bash
$ ls -l ~/bin
lrwxrwxrwx 1 klm users   45 Nov 22 13:37 chicken-mobile -> ~/projects/chicken-mobile/chicken-mobile.scm
$ mkdir /tmp/chicken-mobile-test/ -p
$ cd /tmp/chicken-mobile-test/
$ chicken-mobile
$ find .
```