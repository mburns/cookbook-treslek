Treslek Cookbook
================

[![Build Status](http://img.shields.io/travis/mburns/cookbook-treslek.svg)][travis]
[![Supermarket](http://img.shields.io/cookbook/v/cookbook-treslek.svg)][supermarket]

[travis]: http://travis-ci.org/mburns/cookbook-treslek
[supermarket]: https://supermarket.getchef.com/cookbooks/treslek

IRC bot: https://github.com/jirwin/treslek


Usage
-----
#### treslek::default

e.g.
Just include `treslek` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[treslek]"
  ]
}
```

Contributing
------------
1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
* Michael Burns <michael.burns@rackspace.com>
