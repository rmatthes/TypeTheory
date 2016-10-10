
(** Auxiliary material needed for the development of bicategories, displayed categories, etc, not specific to these but not available in the main library.

Much of this material could probably be moved upstream to the [CategoryTheory] library and elsewhere.

Contents:

  - Notations and tactics
  - Direct products of types
  - Direct products of precategories
  - Pregroupoids
  - Discrete precategories

*)


Require Import UniMath.Foundations.Basics.Sets.
Require Import UniMath.CategoryTheory.precategories.
Require Import UniMath.CategoryTheory.functor_categories.
Require Import UniMath.CategoryTheory.UnicodeNotations.

Require Import UniMath.Ktheory.StandardCategories. 

Require Import TypeTheory.Auxiliary.UnicodeNotations.
Require Import TypeTheory.Auxiliary.Auxiliary.

Local Set Automatic Introduction.
(* only needed since imports globally unset it *)

Bind Scope precategory_scope with precategory_ob_mor.
Bind Scope precategory_scope with precategory_data.
Bind Scope precategory_scope with Precategory.
Bind Scope precategory_scope with precategory.
Delimit Scope precategory_scope with precat.
(** Many binding sorts for this scope, following the many coercions on precategories. *)


(** * Direct products of types.

Lemmas of this subsection are either aliases or mild generalisations of existing functions from the UniMath libraries.  They differ generally in using projections instead of destructing, making them apply and/or reduce in more situations.  The aliases are included just to standardise local naming conventions. *)

Section Dirprod_utils.

(* TODO: check library more thoroughly in case these are already provided. *)

(** Compare [pathsdirprod]. *)
Definition dirprod_paths {A B : UU} {p q : A × B}
  : pr1 p = pr1 q -> pr2 p = pr2 q -> p = q.
Proof.
  destruct p as [a b], q as [a' b']; apply pathsdirprod.
Defined.

(** Compare [total2asstol]. *) 
Definition dirprod_assoc {C0 C1 C2 : UU}
  : (C0 × (C1 × C2)) -> ((C0 × C1) × C2).
Proof.
  intros c. exact ((pr1 c , (pr1 (pr2 c))) , pr2 (pr2 c)). 
Defined.

(** Identical to [dirprodf]. *)
Definition dirprod_maps {A0 A1 B0 B1} (f0 : A0 -> B0) (f1 : A1 -> B1)
  : A0 × A1 -> B0 × B1.
Proof.
  intros aa. exact (f0 (pr1 aa), f1 (pr2 aa)).
Defined.

(** Compare [prodtofuntoprod]. *)
Definition dirprod_pair_maps {A B0 B1} (f0 : A -> B0) (f1 : A -> B1)
  : A -> B0 × B1.
Proof.
  intros a; exact (f0 a, f1 a).
Defined.

End Dirprod_utils.

(** * Direct products of precategories

Construction of finite products of precategories, including functoriality, associativity, and similar infrastructure. *)

Section Precategory_products.

(* TODO: move this upstream to [CategoryTheory]? *)

Definition unit_precategory : precategory.
Proof.
  use tpair. use tpair.
  (* ob, mor *) exists unit. intros; exact unit.
  (* identity, comp *) split; intros; constructor.
  (* id_left *) simpl; split; try split; intros; apply isconnectedunit.
Defined.

Definition unit_functor C : functor C unit_precategory.
Proof.
  use tpair. use tpair.
  (* functor_on_objects *) intros; exact tt.
  (* functor_on_morphisms *) intros F a b; apply identity.
  split.
  (* functor_id *) intros x; apply paths_refl.
  (* functor_comp *) intros x y z w v; apply paths_refl.
Defined.

(* TODO: perhaps generalise to constant functors? *)
Definition ob_as_functor {C : precategory} (c : C) : functor unit_precategory C.
Proof.
  use tpair. use tpair.
  (* functor_on_objects *) intros; exact c.
  (* functor_on_morphisms *) intros F a b; apply identity.
  split.
  (* functor_id *) intros;  constructor.
  (* functor_comp *) intros x y z w v; simpl. apply pathsinv0, id_left.
Defined.

Definition prod_precategory_ob_mor (C D : precategory) : precategory_ob_mor.
  (* ob *) exists (C × D).
  (* mor *) intros a b. refine (_ × _).
    exact ((pr1 a) --> (pr1 b)). exact ((pr2 a) --> (pr2 b)).
Defined.

Definition prod_precategory_data (C D : precategory) : precategory_data.
  exists (prod_precategory_ob_mor C D); split.
  (* identity *) split; apply identity.
  (* comp *) intros a b c f g. 
    exact ((pr1 f ;; pr1 g) , (pr2 f ;; pr2 g)).
Defined.

Definition prod_precategory_is_precategory (C D : precategory)
  : is_precategory (prod_precategory_data C D).
Proof.
  split; try split; try split; intros.
  (* id_left *) apply dirprod_paths; simpl; apply id_left.
  (* id_right *) apply dirprod_paths; simpl; apply id_right. 
  (* assoc *) apply dirprod_paths; simpl; apply assoc.
Qed.

Definition prod_precategory_pre (C D : precategory) : precategory
  := (_ ,, prod_precategory_is_precategory C D).

Definition prod_precategory_homsets (C D : Precategory)
  : has_homsets (prod_precategory_data C D).
Proof.
  intros x y. apply isaset_dirprod; apply homset_property.
Qed.

Definition prod_precategory (C D : Precategory) : Precategory
  := (prod_precategory_pre C D,, prod_precategory_homsets C D).

Arguments prod_precategory (_ _)%precat.

Notation "C × D" := (prod_precategory C D) (at level 75, right associativity) : precategory_scope.

Definition prod_precategory_assoc_data (C0 C1 C2 : Precategory)
  : functor_data (C0 × (C1 × C2)) ((C0 × C1) × C2).
Proof.
  (* functor_on_objects *) exists dirprod_assoc.
  (* functor_on_morphisms *) intros a b; apply dirprod_assoc.
Defined.

Definition prod_precategory_assoc (C0 C1 C2 : Precategory)
  : functor (C0 × (C1 × C2)) ((C0 × C1) × C2).
Proof.
  exists (prod_precategory_assoc_data _ _ _). split.
  (* functor_id *) intros c. simpl; apply paths_refl.
  (* functor_comp *) intros c0 c1 c2 f g. simpl; apply paths_refl.
Defined.

Definition prod_functor_data {C0 C1 D0 D1 : Precategory}
  (F0 : functor C0 D0) (F1 : functor C1 D1)
: functor_data (C0 × C1) (D0 × D1).
Proof.
  (* functor_on_objects *) exists (dirprod_maps F0 F1).
  (* functor_on_morphisms *) intros a b.
    apply dirprod_maps; apply functor_on_morphisms.
Defined.

Definition prod_functor {C0 C1 D0 D1 : Precategory}
  (F0 : functor C0 D0) (F1 : functor C1 D1)
: functor (C0 × C1) (D0 × D1).
Proof.
  exists (prod_functor_data F0 F1); split.
  (* functor_id *) intros c. apply dirprod_paths; apply functor_id.
  (* functor_comp *) intros c0 c1 c2 f g.
    apply dirprod_paths; apply functor_comp.
Defined.

Definition pair_functor_data {C D0 D1 : Precategory}
  (F0 : functor C D0) (F1 : functor C D1)
: functor_data C (D0 × D1).
Proof.
  (* functor_on_objects *) exists (dirprod_pair_maps F0 F1).
  (* functor_on_morphisms *) intros a b.
    apply dirprod_pair_maps; apply functor_on_morphisms.
Defined.

Definition pair_functor {C D0 D1 : Precategory}
  (F0 : functor C D0) (F1 : functor C D1)
: functor C (D0 × D1).
Proof.
  exists (pair_functor_data F0 F1); split.
  (* functor_id *) intros c. apply dirprod_paths; apply functor_id.
  (* functor_comp *) intros c0 c1 c2 f g.
    apply dirprod_paths; apply functor_comp.
Defined.

End Precategory_products.

(** Redeclare section notations to be available globally. *)
Notation "C × D" := (prod_precategory C D)
  (at level 75, right associativity) : precategory_scope.

(** * Pregroupoids *)
Section Pregroupoids.
(* TODO: search library more thoroughly for any of these! *)

Definition is_pregroupoid (C : precategory)
  := forall (x y : C) (f : x --> y), is_iso f.

Lemma is_pregroupoid_functor_precat {C D : Precategory}
  (gr_D : is_pregroupoid D)
  : is_pregroupoid (functorPrecategory C D).
Proof.
  intros F G α; apply functor_iso_if_pointwise_iso.
  intros c; apply gr_D.
Defined.

End Pregroupoids.

(** * Discrete precategories on hSets.

In order to construct locally discrete (pre)bicategories below, we need some infrastructure on discrete (pre)categories. *)
Section Discrete_precats.

Definition discrete_precat (X : hSet) : Precategory.
Proof.
  use tpair.
    apply (path_pregroupoid X).
    apply hlevelntosn, setproperty.
  apply homset_property.
Defined.

Lemma is_pregroupoid_path_pregroupoid {X} {H}
  : is_pregroupoid (path_pregroupoid X H).
Proof.
  intros x y f. apply is_iso_qinv with (!f).
  split. apply pathsinv0r. apply pathsinv0l.
Defined.

(* TODO: check naming conventions; what should this be called? *)
Definition fmap_discrete_precat {X Y : hSet} (f : X -> Y)
  : functor (discrete_precat X) (discrete_precat Y).
Proof.
  use tpair.
  + (* functor_on_objects *) exists f.
    (* functor_on_morphisms *) intros c d. apply maponpaths.
  + split.
    - (* functor_id *) intros x; apply setproperty.
    - (* functor_comp *) intros x y z w v; apply setproperty.
Defined.

Definition prod_discrete_precat (X Y : hSet)
  : functor (discrete_precat X × discrete_precat Y)
            (discrete_precat (X × Y)%set).
Proof.
  use tpair. use tpair.
  + (* functor_on_objects *) apply id.
  + (* functor_on_morphisms *)
    intros a b; simpl. apply uncurry, dirprod_paths.
  + (* functor_id, functor_comp *) split; intro; intros; apply setproperty.
Defined.

Definition discrete_precat_nat_trans {C : precategory} {X : hSet}
  {F G : functor C (discrete_precat X)}
  : (forall c:C, F c = G c) -> nat_trans F G.
Proof.
  intros h. exists h.
  (* naturality *) intros c d f; apply setproperty.
Defined.

End Discrete_precats.

(** * Miscellaneous lemmas *)
Section Miscellaneous.

(* TODO: _surely_ this is in the library!? *)
(** Note: generalises [pr1_transportf]. *)
Definition functtransportf_2
  {X : UU} {P P' : X → UU} (f : forall x, P x -> P' x)
  {x x' : X} (e : x = x') (p : P x)
  : f _ (transportf _ e p) = transportf _ e (f _ p).
Proof.
  destruct e; apply idpath.
Defined.

(* TODO: upstream; also perhaps reconsider implicit args of pr1_transportf to match this? *)
Lemma pr2_transportf {A} {B1 B2 : A → UU} 
    {a a' : A} (e : a = a') (xs : B1 a × B2 a)
  : pr2 (transportf (fun a => B1 a × B2 a) e xs) = transportf _ e (pr2 xs).
Proof.
  destruct e. apply idpath.
Defined.


(** Very handy for reasoning with “dependent paths” — e.g. for algebra in displayed categories.  TODO: perhaps upstream to UniMath?

Note: similar to [transportf_pathsinv0_var], [transportf_pathsinv0'], but not quite a special case of them, or (as far as I can find) any other library lemma.
*)
Lemma transportf_transpose {X : UU} {P : X → UU}
  {x x' : X} (e : x = x') (y : P x) (y' : P x')
: transportb P e y' = y -> y' = transportf P e y.
Proof.
  intro H; destruct e; exact H.
Defined.


(** For use when proving a goal of the form [transportf _ e' y = ?], where [?] is an existential variable, and we want to “compute” in [y], but expect the result of that computing to itself end with a transported term.

Currently named by analogy with monad binding operation (e.g. Haskell’s [ >>= ]), to which it has a curious formal similarity. *)
(* TODO: consider name! *)
(* TODO: try using this in more of the algebraic displayed categories proofs. Frequent use of [transport_f_f] is a sure sign that this would be helpful. *)
Lemma transportf_bind {X : UU} {P : X → UU}
  {x x' x'' : X} (e : x' = x) (e' : x = x'')
  y y'
: y = transportf P e y' -> transportf _ e' y = transportf _ (e @ e') y'.
Proof.
  intro H; destruct e, e'; exact H.
Defined.

(** Composition of dependent paths.

NOTE 1: unfortunately, proofs using this seem to typecheck much more slowly than proofs inlining it as [etrans] plus [transportf_bind] explicitly — a shame, since proofs with this are much cleaner to read.

NOTE 2: unfortunately there’s a variance issue: this is currently backwards over paths in the base.  However, this is unavoidable given that:

- we want the LHS of the input equalities to be an aribtrary term, *not* a transported term, so that proofs can work in “compute left-to-right” style;
- we want an arbitrary [transportf] on the RHS of the input equalities, so that this lemma can accept whatever the “computation” produces.

If [transportf] were derived from [transportb], instead of vice versa, then we could use [transportb] on the RHS and this would look much nicer… *)
Lemma pathscomp0_dep {X : UU} {P : X → UU}
  {x x' x'' : X} {e : x' = x} {e' : x'' = x'}
  {y} {y'} {y''}
: (y = transportf P e y') -> (y' = transportf _ e' y'')
  -> y = transportf _ (e' @ e) y''.
Proof.
  intros ee ee'.
  etrans. apply ee.
  apply transportf_bind, ee'.
Defined.

Tactic Notation "etrans_dep" := eapply @pathscomp0_dep.


End Miscellaneous.
