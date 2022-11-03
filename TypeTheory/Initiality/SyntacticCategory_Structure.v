Require Import UniMath.MoreFoundations.All.

Require Import UniMath.CategoryTheory.Core.Categories.

Require Import TypeTheory.Auxiliary.Auxiliary.
Require Import TypeTheory.Auxiliary.CategoryTheory.
Require Import TypeTheory.TypeCat.TypeCat.
Require Import TypeTheory.TypeCat.General.
Require Import TypeTheory.TypeCat.Structure.
Require Import TypeTheory.Initiality.Syntax.
Require Import TypeTheory.Initiality.SyntaxLemmas.
Require Import TypeTheory.Initiality.Typing.
Require Import TypeTheory.Initiality.TypingLemmas.
Require Import TypeTheory.Initiality.SyntacticCategory.

Section Universe_Structure.

  Local Definition basetype_struct_syntactic_typecat :
    basetype_struct syntactic_typecat.
  Proof.
    use tpair.
    + intros ΓΓ.
      apply setquotpr.
      exists U_expr.
      intros Γ.
      apply hinhpr, derive_U.
    + simpl; intros ΓΓ ΔΔ.
      use setquotunivprop'. { intros; apply isasetsetquot. } intros f.
      apply iscompsetquotpr; cbn.
      intros Δ.
      apply hinhpr, derive_tyeq_refl, derive_U.
  Defined.

  Local Definition deptype_struct_syntactic_typecat :
    deptype_struct _ basetype_struct_syntactic_typecat.
  Proof.
    use tpair.
    - cbn.
      intros ΓΓ [t ht].
      apply (take_context_representative ΓΓ). { admit. } intros Γ.
      revert t ht; use setquotunivprop'. { admit. } simpl; intros f hf.
      use setquotpr.
      use tpair.
      + apply El_expr.
        admit. (* How to turn a tm into a tm_expr? *)
      + simpl.
        admit.
    - admit.
  Admitted. (* [deptype_struct_syntactic_typecat]: reasonably self-contained, probably needs a little more infrastructure on syntactic cat *)

  Local Definition univ :
    universe_struct syntactic_typecat
    := (basetype_struct_syntactic_typecat,,deptype_struct_syntactic_typecat).
  
End Universe_Structure.

Section Pi_Structure.

  Local Definition pi_form_struct_syntactic_typecat :
    pi_form_struct syntactic_typecat.
  Admitted. (* [pi_form_struct_syntactic_typecat]: reasonably self-contained, probably needs a little more infrastructure on syntactic cat *)

  Local Definition pi_intro_struct_syntactic_typecat : 
    pi_intro_struct _ pi_form_struct_syntactic_typecat.
  Admitted. (* [pi_intro_struct_syntactic_typecat]: depends on [pi_form_…], thereafter reasonably self-contained *)

  Local Definition pi_app_struct_syntactic_typecat : 
    pi_app_struct _ pi_form_struct_syntactic_typecat.
  Admitted. (* [pi_app_struct_syntactic_typecat]: depends on [pi_form_…], thereafter reasonably self-contained *)

  Local Definition pi_comp_struct_syntactic_typecat :
    pi_comp_struct syntactic_typecat pi_intro_struct_syntactic_typecat
                                     pi_app_struct_syntactic_typecat.
  Admitted. (* [pi_comp_struct_syntactic_typecat]: depends on [pi_intro_…] and [pi_app_…], thereafter reasonably self-contained *)
  
  Local Definition pi : pi_struct syntactic_typecat
    := (pi_form_struct_syntactic_typecat,,
       (pi_intro_struct_syntactic_typecat,,pi_app_struct_syntactic_typecat),,
        pi_comp_struct_syntactic_typecat).

End Pi_Structure.
