# autoload-checker

Checks for conflicts in class/module definitions and corrects them. For instance, you have
a file `foo/bar/baz.rb` with following content:

```ruby
module Foo
  module Bar
    class Baz
    end
  end
end
```

And a file `foo/bar.rb` with following content:

```ruby
module Foo
  class Bar
  end
end
```

So, when you start your app, "Bar is not a class" exception will be thrown. autoload_checker
detects conflict definitions and fix them by replacing `module Bar` with `class Bar`
in `foo/bar/baz.rb`.

# Usage

```
Usage: ./bin/autoload_checker.rb [options]
    -p, --path DIR,...               [Mandatory] directories to check
    -c, --correct                    Enable errors correction
    -h, --help                       Prints this help
```
