using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SelectVue : MonoBehaviour {

	public Camera camGenerale;
	public float delaiValidation;
	public Color couleurDepart;
	public Color couleurSelection;
	public Color couleurValidation;

	private Ray rayonCamera;
	private bool selectionActive = false;
	private GameObject objetSelectionne;

	private float momentSelection = 0.0f;

	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		projetteRayon ();
		if (selectionActive && Time.time - momentSelection > delaiValidation) {
			valide ();
		}
	}

	void projetteRayon()
	{
		RaycastHit hit;
		if (Physics.Raycast (camGenerale.transform.position, camGenerale.transform.rotation * Vector3.forward, out hit)) {
			GameObject objectHit = hit.collider.gameObject;
			//Verifier que la selection est nécessaire : aucune séléction ou changement de séléction
			if ((!selectionActive) && objectHit.tag == "selectable" && objectHit != objetSelectionne) {
				selectionne (objectHit);
			//Déselection si séléction active si objet non selectable
			} else if (selectionActive && objectHit.gameObject.tag != "selectable") {
				deSelectionne ();
			}
		//Déselection si rien n'a été touché
		} else {
			deSelectionne ();
		}
	}

	void selectionne(GameObject sel)
	{
		deSelectionne ();
		selectionActive = true;
		objetSelectionne = sel;
		momentSelection = Time.time;
		//Test couleur rouge
		changeCouleur(couleurSelection);
	}

	void deSelectionne()
	{
		selectionActive = false;
		momentSelection = 0.0f;
		if (objetSelectionne != null) {
			changeCouleur(couleurDepart);
			objetSelectionne = null;
		}
	}

	void valide()
	{
		changeCouleur (couleurValidation);
	}

	void changeCouleur(Color coul)
	{
		MeshRenderer rendeur;
		Material mat;
		rendeur = objetSelectionne.GetComponent<MeshRenderer> ();
		mat = rendeur.material;
		mat.color = coul;
	}





}
