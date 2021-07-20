/**
 * Created by fabiankramer on 12.07.21.
 */

    ({
        init : function (component) {
            // Find the component whose aura:id is "flowData"

            var inputVariables = [{ recordId : component.get("v.recordId")}];
            var flow = component.find("flowData");
            // In that component, start your flow. Reference the flow's API Name.
            flow.startFlow("ScreenFlowBeServe",inputVariables);
        },
    })