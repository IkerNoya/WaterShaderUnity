using System;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using Unity.VisualScripting.Dependencies.NCalc;
using UnityEngine;

public class Floater : MonoBehaviour
{
    [SerializeField] private Rigidbody rb;
    [SerializeField] private float depthBeforeSubmerged = 1f;
    [SerializeField] private float displacementAmount = 3f;
    [SerializeField] private int floaterCount = 1;
    [SerializeField] private float waterDrag = .99f;
    [SerializeField] private float waterAngularDrag = .5f;

    private Mesh _waterMesh;
    private MeshFilter _waterMeshFilter;

    float CalculateWaterHeight(Vector3 position)
    {
        RaycastHit Hit;
        Ray ray = new Ray();
        ray.origin = position;
        ray.direction = Vector3.down;
        Debug.DrawRay(ray.origin, ray.direction * 100, Color.red);
        if (Physics.Raycast(ray, out Hit, 100))
        {
            if (!_waterMesh && !_waterMeshFilter)
            {
                _waterMeshFilter = Hit.transform.gameObject.GetComponent<MeshFilter>();
                _waterMesh = _waterMeshFilter.mesh;
            }
            Vector3[] vertices = _waterMesh.vertices;
            int[] triangles = _waterMesh.triangles;
            Vector3 p0 = vertices[triangles[Hit.triangleIndex * 3 + 0]];
            Vector3 p1 = vertices[triangles[Hit.triangleIndex * 3 + 1]];
            Vector3 p2 = vertices[triangles[Hit.triangleIndex * 3 + 2]];
            Vector3 xd = vertices[triangles[GetClosestVertex(Hit, triangles)]];
            return xd.y;
        }
        return 0f;
    }
    
    public int GetClosestVertex(RaycastHit aHit, int[] aTriangles)
    {
        var b = aHit.barycentricCoordinate;
        int index = aHit.triangleIndex * 3;
        if (aTriangles == null || index < 0 || index + 2 >= aTriangles.Length)
            return -1;
        if (b.x > b.y)
        {
            if (b.x > b.z)
                return aTriangles[index]; // x

            return aTriangles[index + 2]; // z
        }
        if (b.y > b.z)
            return aTriangles[index + 1]; // y
        
        return aTriangles[index + 2]; // z
    }

    private void FixedUpdate()
    {
        Vector3 position = transform.position;
        Vector3 gravityForce = Physics.gravity / floaterCount;
        if (!float.IsNaN(gravityForce.x) && !float.IsNaN(gravityForce.y) && !float.IsNaN(gravityForce.z))
            rb.AddForceAtPosition(Physics.gravity / floaterCount, position, ForceMode.Acceleration);
        float waveHeight = CalculateWaterHeight(position);
        Debug.Log("waveHeight: " + waveHeight);
        if (transform.position.y < waveHeight)
        {
            float displacementMultiplier = Mathf.Clamp01(waveHeight - transform.position.y / depthBeforeSubmerged) * displacementAmount;
            rb.AddForceAtPosition(new Vector3(0f, Math.Abs(Physics.gravity.y) * displacementMultiplier, 0f), position, ForceMode.Acceleration);
            rb.AddForce(-rb.velocity * (displacementMultiplier * waterDrag * Time.fixedDeltaTime), ForceMode.VelocityChange);
            rb.AddTorque(-rb.angularVelocity * (displacementMultiplier * waterAngularDrag * Time.fixedDeltaTime), ForceMode.VelocityChange);
        }
    }
}
