using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Floater : MonoBehaviour
{
    [SerializeField] private Rigidbody rb;
    [SerializeField] private float depthBeforeSubmerged = 1f;
    [SerializeField] private float displacementAmount = 3f;
    [SerializeField] private int floaterCount = 1;
    [SerializeField] private float waterDrag = .99f;
    [SerializeField] private float waterAngularDrag = .5f;

    private void FixedUpdate()
    {
        Vector3 position = transform.position;
        Vector3 gravityForce = Physics.gravity / floaterCount;
        if(!float.IsNaN(gravityForce.x) && !float.IsNaN(gravityForce.y) && !float.IsNaN(gravityForce.z))
            rb.AddForceAtPosition(Physics.gravity / floaterCount, position, ForceMode.Acceleration);
        float waveHeight = WaveManager.instance.GetWaveHeight(position.x);
        if (transform.position.y < waveHeight)
        {
            float displacementMultiplier = Mathf.Clamp01(waveHeight - transform.position.y / depthBeforeSubmerged) * displacementAmount;
            rb.AddForceAtPosition(new Vector3(0f, Math.Abs(Physics.gravity.y) * displacementMultiplier, 0f), position, ForceMode.Acceleration);
            rb.AddForce(-rb.velocity * (displacementMultiplier * waterDrag * Time.fixedDeltaTime), ForceMode.VelocityChange);
            rb.AddTorque(-rb.angularVelocity * (displacementMultiplier * waterAngularDrag * Time.fixedDeltaTime), ForceMode.VelocityChange);
        }
    }
}
