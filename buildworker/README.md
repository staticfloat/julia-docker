buildworker docker images
=========================

To build Julia buildworker base docker images, first install [harbor](https://github.com/leethomas/harbor) with `gem install harbordock`, then run `make` in this directory.  The result will be docker images named things like `buildworker_centos5:64` and `buildworker_ubuntu16.04:32`.
