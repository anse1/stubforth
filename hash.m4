define(`ord', `changequote(.[,.])ord1(255, .[$1.])resetquote')
changequote(.[,.])
define(.[resetquote.], .[changequote(`,').])
define(.[ord1.], .[ifelse($1, 0, 0, .[ifelse(.[$2.], format(.[.[%c.].],$1),$1,.[ord1(decr($1),.[$2.]).]).]).])
changequote(`,')

define(`hash_prime', 2039)

dnl char: substr(`$1',decr(len(`$1')),1)
dnl recurse: substr(`$1',0,decr(len(`$1')))


changequote(.[,.])
define(.[quote.], .[$@.])
define(.[rest.], .[quote(substr(.[$1.],0,decr(len(.[$1.])))).])
define(.[char.], .[quote(substr(.[$1.],decr(len(.[$1.])),1)).])
define(.[m4hash1.], .[ifelse(len(.[$1.]),0,0,
	.[eval(m4hash1(rest(.[$1.])) * hash_prime
              + ord1(255, char(.[$1.]))) .]).])
changequote(`,')
define(`m4hash', `changequote(.[,.])m4hash1(quote(.[$1.]))resetquote')

cell chash(const char *s)
{
    cell c;
    c.i = *s++;
    while (*s) {
      c.i = c.i * hash_prime + *s;
      s++;
    }
    return c;
}
