#include "all.h"

u3_atom
u3qdu_qor_size(u3_noun t)
{
  if ( u3_nul == t ) {
    return 0;
  }
  else {
    u3_atom pro = u3k(u3h(u3t(t)));

    if ( c3n == u3ud(pro) ) {
      return u3m_bail(c3__exit);
    }
    else {
      return pro;
    }
  }
}

u3_noun
u3wdu_qor_size(u3_noun cor)
{
  u3_noun t;

  if ( (c3n == u3r_mean(cor, u3x_sam, &t, 0)) )
  {
    return u3m_bail(c3__exit);
  } else {
    return u3qdu_qor_size(t);
  }
}
