module Practice.Hoon2DependentHoon4 where

import ClassyPrelude

import Practice.DependentHoon4
import Practice.HoonCommon hiding (Bass(..))
import qualified Practice.HoonCommon as HC
import Practice.HoonSyntax

type Desugar = Either Text

open :: Hoon -> Desugar Soft
open = \case
  Wung w -> pure $ Wng w
  Wild -> Left "open-skin: unexpected '_' in non-skin position"
  Adam g a au -> pure $ Atm a g au
  --
  Bass HC.Non -> pure $ Non
  Bass HC.Cel -> pure $ Cel Non Non
  Bass HC.Flg -> pure $ Aur "f" (Fork $ setFromList [0, 1])
  Bass HC.Nul -> pure $ Aur "n" (Fork $ setFromList [0])
  -- XX Aura
  Bass (HC.Fok as au) -> pure $ Aur au (Fork $ setFromList as)
  Bass HC.Vod -> pure $ Vod
  Bass (HC.Aur au) -> pure $ Aur au Bowl
  Bass HC.Typ -> pure $ Typ
  Bcbr{} -> Left "unsupported $|"
  Bccb h -> Left "unsupported _"
  Bccl s [] -> open s
  Bccl s (s':ss) -> Ral <$> open s <*> open (Bccl s' ss)
  Bccn [] -> pure $ Vod
  Bccn cs -> do
    let fork = Bass $ HC.Fok [a | (a, _, _) <- cs] "" -- FIXME aura
    let pats = [(Adam Rock a au, s) | (a, au, s) <- cs]
    open $ Bccl fork [Kthp (Bass HC.Typ) $ Wthp [Axis 2] pats]
  Bcgr t ss -> Left "unsupported $>" --Fok <$> open t <*> traverse flay ss
  Bcgl{} -> Left "unsupported $<"
  Bchp s t -> Gat <$> open s <*> open t
  Bckt{} -> Left "unsupported $^"
  Bcts h s -> Sin <$> open h <*> open s
  Bcpt{} -> Left "unsupported $@"
  Bcwt{} -> Left "unsupported $?"
  --
  Brcn{} -> Left "unsupported |%"
  Brts t h -> Lam <$> open t <*> open h
  --
  Clcb h j -> Cel <$> open j <*> open h
  Clkt h j k l -> Cel <$> open h
                       <*> (Cel <$> open j
                                 <*> (Cel <$> open k
                                           <*> open l))
  Clhp h j -> Cel <$> open h <*> open j
  Clls h j k -> Cel <$> open h <*> (Cel <$> open j <*> open k)
  Clsg [] -> pure $ Atm 0 Rock "n"
  Clsg (h:hs) -> Cel <$> open h <*> open (Clsg hs)
  Cltr [] -> Left "empty :*"
  Cltr [h] -> open h
  Cltr (h:hs) -> Cel <$> open h <*> open (Cltr hs)
  --
  Cndt h j -> Sla <$> open j <*> open h
  Cnhp h j -> Sla <$> open h <*> open j
  Cncl h hs -> Sla <$> open h <*> open (Cltr hs)
  Cnkt h j k l -> Sla <$> open h
                       <*> (Sla <$> open j
                                 <*> (Sla <$> open k
                                           <*> open l))
  Cnls h j k -> Sla <$> open h <*> (Sla <$> open j <*> open k)
  Cnts{} -> Left "unsupported %="
  --
  Dtkt{} -> Left "unsupported .^"
  Dtls h -> Plu <$> open h
  Dttr{} -> Left "unsupported .*"
  Dtts h j -> Equ <$> open h <*> open j
  Dtwt h -> open $ Wtts (Clhp Wild Wild) h  -- TODO gets converted back later
  --
  Ktls{} -> Left "unsupported ^+"
  Kthp s h -> do typ <- open s; sof <- open h; pure Net {typ, sof}
  Ktfs h s -> do typ <- open s; sof <- open h; pure Net {typ, sof}
  Ktzp s h -> do typ <- open s; sof <- open h; pure Cat {typ, sof}
  Ktwt h -> Left "unsupported ^? lead cast"  -- XX fixme soon
  Ktts s h -> Fac <$> flay s <*> open h
  Ktcn h -> Left "unsupported ^%"
  Ktcl{} -> Left "unsupported ^: mold"
  --
  Sgfs{} -> Left "unsupported ~/"
  --
  Tsfs s h j -> open $ Tsls (Ktts s h) j
  Tsmc s h j -> open $ Tsfs s j h
  Tsdt{} -> Left "unsupported =."
  Tswt{} -> Left "unsupported =?"
  --Tsgl (Brcn m) h -> cook h m unname open (flip Core)
  Tsgl h j -> open $ Tsgr j h
  --Tsgr h (Brcn m) -> cook h m unname open (flip Core)
  Tsgr h j -> Wit <$> open h <*> open j
  Tshp h j -> open $ Tsls j h
  Tskt{} -> Left "unsupported =^"
  Tsls h j -> Pus <$> open h <*> open j
  Tssg{} -> Left "unsupported =~"
  --
  Wtbr{} -> Left "unsupported ?|"
  Wthp w [] -> Left "empty ?-"
  Wthp w [(s, h)] -> Rhe <$> open (Wtts s $ Wung w) <*> open h
  Wthp w ((s, h):cs) ->
    Tes <$> open (Wtts s $ Wung w) <*> open h <*> open (Wthp w cs)
  Wtcl h j k -> Tes <$> open h <*> open j <*> open k
  Wtdt h j k -> open $ Wtcl j h k
  -- we possibly want to move "^" from being a type to being a skin exclusively
  Wtkt w h j -> open $ Wtcl (Wtts (Clhp Wild Wild) (Wung w)) h j
  Wtgl{} -> Left "unsupported ?>"
  Wtgr{} -> Left "unsupported ?<"
  Wtpm{} -> Left "unsupported ?&"
  -- this suggests we probably want a skin notation for "any atom"; "@@"?
  Wtpt w h j -> open $ Wtcl (Wtts (Clhp Wild Wild) (Wung w)) j h
  Wtts s h -> Fis <$> flay s <*> open h
  Wtwt h j -> Rhe <$> open h <*> open j
  Wtzp{} -> Left "unsupported ?!"
  --
  Zpzp -> Left "unsupported !!"
  --
  Hxgl{} -> Left "not available in user syntax: #<"
  Hxgr{} -> Left "not available in user syntax: #>"

flay :: Hoon -> Desugar Pelt
flay = \case
  Wild -> pure Punt
  Wung [Ally f] -> pure $ Peer f
  Adam g a au -> pure $ Part a
  --
  Clcb h j -> Pair <$> flay j <*> flay h
  Clkt h j k l -> Pair <$> flay h
                       <*> (Pair <$> flay j
                                 <*> (Pair <$> flay k
                                           <*> flay l))
  Clhp h j -> Pair <$> flay h <*> flay j
  Clls h j k -> Pair <$> flay h <*> (Pair <$> flay j <*> flay k)
  Clsg [] -> pure $ Part 0
  Clsg (h:hs) -> Pair <$> flay h <*> flay (Clsg hs)
  Cltr [] -> Left "empty :*"
  Cltr [h] -> flay h
  Cltr (h:hs) -> Pair <$> flay h <*> flay (Cltr hs)
  --
  Kthp t h -> Pest <$> flay h <*> open t
  Ktfs h t -> Pest <$> flay h <*> open t
  Ktzp t h -> Past <$> flay h <*> open t
  --
  h -> Left ("flay-meat: expression in pattern context: " <> tshow h)

shut :: Soft -> Hoon
shut = \case
  Wng w -> Wung w
  --
  Atm a g au -> Adam g a au
  Cel c d -> case shut d of
    Clhp h j -> Clls (shut c) h j
    Clls h j k -> Clkt (shut c) h j k
    Clkt h j k l -> Cltr [shut c, h, j, k, l]
    Cltr hs -> Cltr (shut c : hs)
    h -> Clhp (shut c) h
  Lam c d -> Brts (shut c) (shut d)
  Fac p c -> Ktts (flap p) (shut c)
  --Core b p -> Tsgr (shut p) (Brcn $ fmap (shut (unname e p) . fromScope) b)
  --
  Plu c -> Dtls (shut c)
  Sla c d -> case shut d of
    Clhp h j -> Cnls (shut c) h j
    Clls h j k -> Cnkt (shut c) h j k
    Clkt h j k l -> Cncl (shut c) [h, j, k, l]
    Cltr hs -> Cncl (shut c) hs
    h -> Cnhp (shut c) h
  Equ c d -> Dtts (shut c) (shut d)
  Tes c d e -> Wtcl (shut c) (shut d) (shut e)
  Rhe c d -> Wtwt (shut c) (shut d)
  Fis p c -> Wtts (flap p) (shut c)
  --
  Aur au Bowl -> Bass (HC.Aur au)
  Aur "n" (Fork as) | as == setFromList [0] -> Bass HC.Nul
  Aur "f" (Fork as) | as == setFromList [0, 1] -> Bass HC.Flg
  Aur au (Fork as) -> Bass (HC.Fok (toList as) au)
  Ral c d -> case shut d of
    Bccl s ss -> Bccl (shut c) (s:ss)
    s -> Bccl (shut c) [s]
  Gat c d -> Bchp (shut c) (shut d)
  --Fok t ss -> Bcgr (shut t) (map flap ss)
  Sin c t -> Bcts (shut c) (shut t)
  Fus c p -> Bcgr (shut c) (flap p)
  Non -> Bass HC.Non
  Vod -> Bass HC.Vod
  Typ -> Bass HC.Typ
  --
  Wit c d -> Tsgr (shut c) (shut d)
  Pus c d -> Tsls (shut c) (shut d)
  --Case c ss ds -> error "open: case"
  Net{sof, typ} -> Kthp (shut typ) (shut sof)  -- XX should print as / wide
  Cat{sof, typ} -> Ktzp (shut typ) (shut sof)

flap :: Pelt -> Hoon
flap = \case
  Punt -> Wild
  Peer f -> Wung [Ally f]
  Part a -> Adam Rock a (heuAura a)
  Pair p q -> case flap q of
    Clhp h j -> Clls (flap p) h j
    Clls h j k -> Clkt (flap p) h j k
    Clkt h j k l -> Cltr [flap p, h, j, k, l]
    Cltr hs -> Cltr (flap p : hs)
    h -> Clhp (flap p) h
  --Pons p q -> Ktts (flap p) (flap q)
  Pest p c -> Ktfs (flap p) (shut c)
  Past p c -> Ktzp (shut c) (flap p)

-- | Hack to make Bases pretty printable somehow. This is for the implementor
-- and should not be used in user-facing diagnostics.
lock :: Var a => Semi a -> Hoon
lock = \case
  Rump' r -> Wung [Ally $ tshow r]
  Fore' x -> Wung [Ally $ tshow $ Old @Text x]
  --
  Atom' a -> Adam Sand a (heuAura a)
  Cell' x y -> case lock y of
    Clhp h j -> Clls (lock x) h j
    Clls h j k -> Clkt (lock x) h j k
    Clkt h j k l -> Cltr [lock x, h, j, k, l]
    Cltr hs -> Cltr (lock x : hs)
    h -> Clhp (lock x) h
  Lamb' (Jamb c x) -> Tsgr (lock x) $ Brts Wild (shut . rest $ c)
  --
  Plus' x -> Dtls (lock x)
  Slam' x y ->  case lock y of
    Clhp h j -> Cnls (lock x) h j
    Clls h j k -> Cnkt (lock x) h j k
    Clkt h j k l -> Cncl (lock x) [h, j, k, l]
    Cltr hs -> Cncl (lock x) hs
    h -> Cnhp (lock x) h
  Equl' x y -> Dtts (lock x) (lock y)
  Test' x y z -> Wtcl (lock x) (lock y) (lock z)
  Fish' f x -> Wtts (flap $ pond f) (lock x)
  Look' x (Leg a) -> Tsgl (Wung [Axis a]) (lock x)
  --
  Aura' au Bowl -> Bass (HC.Aur au)
  Aura' "n" (Fork as) | as == setFromList [0] -> Bass HC.Nul
  Aura' "f" (Fork as) | as == setFromList [0, 1] -> Bass HC.Flg
  Aura' au (Fork as) -> Bass (HC.Fok (toList as) au)
  Rail' t (Jamb c s) -> Tsgr (lock s) $ Bccl (lock t) case shut . rest $ c of
    Bccl h hs -> h:hs
    h -> [h]
  Gate' t (Jamb c s) ->
    Tsgr (lock s) $ Bchp (lock t) (shut . rest $ fmap hack c)
--  Fork' fs t -> Bcgr (lock t) (map (flap . pond) $ setToList fs)
  Sing' x y -> Bcts (lock x) (lock y)
  Fuse' x f -> Bcgr (lock x) (flap $ pond f)
  Face' (Mask m) x -> Ktts (Wung [Ally m]) (lock x)
  Face' (Link ls) x -> Ktts Wild (lock x)  -- FIXME ?
  Noun' -> Bass HC.Non
  Void' -> Bass HC.Vod
  Type' -> Bass HC.Typ
 where
  hack :: Show a => a -> Wing
  hack = singleton . Ally . tshow
