define(`ord', `changequote(.[,.])ord1(255, .[$1.])resetquote')
changequote(.[,.])
define(.[resetquote.], .[changequote(`,').])
define(.[ord1.], .[ifelse($1, 0, 0, .[ifelse(.[$2.], format(.[.[%c.].],$1),$1,.[ord1(decr($1),.[$2.]).]).]).])
changequote(`,')

define(`hash_prime', 2039)

dnl char: substr(`$1',decr(len(`$1')),1)
dnl recurse: substr(`$1',0,decr(len(`$1')))


changequote(.[,.])
define(.[hashquote.], .[$@.])
define(.[hashrest.], .[hashquote(substr(.[$1.],0,decr(len(.[$1.])))).])
define(.[hashchar.], .[hashquote(substr(.[$1.],decr(len(.[$1.])),1)).])
define(.[m4hash1.], .[ifelse(len(.[$1.]),0,0,
	.[eval(m4hash1(hashrest(.[$1.])) * hash_prime
              + ord1(255, hashchar(.[$1.]))) .]).])
changequote(`,')
define(`m4hash', `changequote(.[,.])m4hash1(quote(.[$1.]))resetquote')

vmint chash(const char *s)
{
    vmint i;
    i = *s++;
    while (*s) {
      i = i * hash_prime + *s;
      s++;
    }
    return i;
}
