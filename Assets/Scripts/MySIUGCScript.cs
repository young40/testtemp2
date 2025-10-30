using UnityEngine;

class MyNode
{
    public int mMyNodeId;
}

public class MySIUGCScript : MonoBehaviour
{
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        MyNode node = new MyNode();
        node.mMyNodeId = 1001;
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    void OnGUI()
    {
        GUIStyle style = new GUIStyle();
        style.fontSize = 50;
        style.alignment = TextAnchor.MiddleCenter;
        style.normal.textColor = Color.red;

        Rect rect = new Rect(100, 100, 100, 100);
        GUI.Label(rect, "Hello GC", style);
    }
}
