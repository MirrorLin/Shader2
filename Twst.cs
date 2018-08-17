using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Twst : MonoBehaviour {

    PlayerState state;

	// Use this for initialization
	void Start () {
        Debug.Log((int)PlayerState.Run);
	}
	
	// Update is called once per frame
	void Update () {
		
	}
}


public enum PlayerState
{
    Run,
    Jump,
    Die
}
