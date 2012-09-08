#!/bin/sh

nm -t d  "$@" | sort | tac |
  perl -pe '($this) = /^(\d+)/;
            if ($n) { printf "%08d ", ($n - $this) } ;
            $n = $this;'| tac | sort
