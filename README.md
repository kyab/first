# first
Scripting language supporting goroutine.

## Execute sample 
run `make` to compile interpreter and execute first.sample.code
```
$ make
...
...
-----evaluate-----(nest 0)
> putting abc...
> 3200
> putting foo...
> 46
> hello world
block evaluating
-----evaluate-----(nest 1)
> in block...
> 20000
> in block...done
-----evaluate-----(nest 1) done
goroutine evaluating
goroutine evaluating
-----evaluate-----(nest -1)
> in goroutine...1
-----evaluate-----(nest -1)
> in goroutine...2
> in goroutine...1
> in goroutine...1
> in goroutine...2
> goroutine1 exit
> in goroutine...1
> in goroutine...1
> in goroutine...2
> in goroutine...1
> goroutine1 exit
-----evaluate-----(nest -1) done
> goroutine2 exit
-----evaluate-----(nest -1) done
> done!
-----evaluate-----(nest 0) done
```



