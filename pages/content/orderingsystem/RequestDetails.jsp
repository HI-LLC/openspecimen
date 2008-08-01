<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-logic" prefix="logic" %>
<%@ page import="edu.wustl.catissuecore.util.global.Constants" %>
<%@ page import="edu.wustl.common.util.global.ApplicationProperties" %>
<%@ page import="java.util.List"%>
<%@ page import="edu.wustl.catissuecore.bean.RequestViewBean" %>
<script src="jss/ajax.js"></script>	   


<html:messages id="messageKey" message="true" header="messages.header" footer="messages.footer">
	<%=messageKey%>
</html:messages>
<html:errors/>

<head>
<%
List requestDetailsList = new ArrayList();
if(request.getAttribute(Constants.REQUEST_DETAILS_LIST) != null )
	requestDetailsList = (List) request.getAttribute(Constants.REQUEST_DETAILS_LIST);	
else 
	requestDetailsList = (List) session.getAttribute(Constants.REQUEST_DETAILS_LIST);	
int disabledStatus;
int count=0;
if(requestDetailsList!=null && requestDetailsList.size()>0 )
{
 count=requestDetailsList.size();	
}
String form_action = Constants.SUBMIT_REQUEST_DETAILS_ACTION+"?submittedFor=ForwardTo&noOfRecords="+count;;
%>
<script language="JavaScript" type="text/javascript" src="jss/javaScript.js"></script>
<script language="JavaScript" type="text/javascript" src="jss/ajax.js"></script>
<script language="JavaScript" type="text/javascript" src="jss/OrderingSystem.js"></script>
<script language="javascript">
var newWindow;

function changeCreateButtonStatus(noOfItems,arrayRowCounter,assignStatusArraycount)
{
	var buttonCreateArrayId = "buttonCreateArrayId"+arrayRowCounter;
	var obj = document.getElementById(buttonCreateArrayId);
	obj.disabled=false;
	var index = assignStatusArraycount-noOfItems;
	for(i=index;i<assignStatusArraycount;i++)
	{

		var assignStatusArrayId = "value(DefinedArrayDetailsBean:"+i+"_assignedStatus)"+arrayRowCounter; 	
		var assignStatusArrayValue =  document.getElementById(assignStatusArrayId).value;
		if(assignStatusArrayValue!="Ready For Array Preparation")
		{
			obj.disabled=true;
			break;
		}
		
	}

}

function tabToDisplay()
{
	var tabIndex = document.getElementById("tabIndexId").value;
	if(tabIndex == 1)
	{
		gotoSpecimenRequestTab();
	}
	else
	{
		gotoArrayRequestTab();
	}
}
	function getUnit(classname,type)
		{
			if(classname == "Tissue")
			{
				if(type == "<%=Constants.FROZEN_TISSUE_SLIDE%>" || type =="<%=Constants.FIXED_TISSUE_BLOCK%>" || type == "<%=Constants.FROZEN_TISSUE_BLOCK%>" || type == "<%=Constants.NOT_SPECIFIED%>" || type == "<%=Constants.FIXED_TISSUE_SLIDE%>")
				{
					return("<%=Constants.UNIT_CN%>");
				}	
				else 
				{
						if(type == "<%=Constants.MICRODISSECTED%>")
						{
							return("<%=Constants.UNIT_CL%>");
						}
						else
						{
							return("<%=Constants.UNIT_GM%>");
						}
				}	
			}
			else if(classname == "Fluid")
			{
				return("<%=Constants.UNIT_ML%>");
			}
			else if(classname == "Cell")
			{
				return("<%=Constants.UNIT_CC%>");
			}
			else if(classname == "Molecular")
			{
				return("<%=Constants.UNIT_MG%>");
			}

		}
function showSpecimenDetails(id)
{
	showNewPage('SearchObject.do?pageOf=pageOfNewSpecimen&operation=search&id=' + id );
}
function showSpecimenArrayDetails(id)
{
	showNewPage('SearchObject.do?pageOf=pageOfSpecimenArray&operation=search&id=' + id );
}
function showNewPage(action)
{
   	if(newWindow!=null)
	{
	   newWindow.close();
	}
     newWindow = window.open(action,'','scrollbars=yes,status=yes,resizable=yes,width=860, height=600');
     newWindow.focus(); 
	
}	
function submitAndNotify()
{
	document.getElementById("mailNotification").value= "true";
	document.forms[0].submit();
}
//this function used to view all the consents
function showAllSpecimen(count)
{

	var speciemnIdValue="";
	var labelIndexCount="";
	var verifiedRows="";
	var iCount=0;

	for(i=0;i<count;i++)
	{
		var consentVerificationkey= "value(RequestDetailsBean:"+i+"_consentVerificationkey)";
		var rowstatus= "value(RequestDetailsBean:"+i+"_rowStatuskey)";
		
		var statusValue =  document.getElementById(rowstatus).value;
		
		var status = document.getElementById(consentVerificationkey).value;
	
		if(status=="<%=Constants.VIEW_CONSENTS%>"||status=="<%=Constants.VERIFIED%>" && statusValue!="disable")
		{
			var specimenkey= "value(RequestDetailsBean:"+i+"_specimenId)";
			var specimenObj= document.getElementById(specimenkey);
			speciemnIdValue= speciemnIdValue+document.getElementById(specimenkey).value;
			labelIndexCount=labelIndexCount+i;
			if(i!=count)
			{
				speciemnIdValue=speciemnIdValue+"|";
				labelIndexCount=labelIndexCount+"|";
			}
			if(status=="<%=Constants.VERIFIED%>")
			{
				verifiedRows=verifiedRows+(i-iCount)+",";
			}

		}
		else
		{
			iCount=iCount+1;
		}
	
	}
	if(count==(iCount))
	{
		alert("No consents available");
	}
	else
	{
			
		
		var url= 'ConsentVerification.do?operation=&pageOf=pageOfOrdering&specimenConsents=yes&verifiedRows='+verifiedRows+'&noOfRows='+count+'&speciemnIdValue='+speciemnIdValue+'&labelIndexCount='+labelIndexCount;
		window.open(url,'ConsentVerificationForm','height=300,width=800,scrollbars=1,resizable=1');
	}
}
//This function called to view the consent page
function showNewConsentPage(specimenIdentifierkey,labelStatus,consentVerificationkey)
{	
	var status = document.getElementById(consentVerificationkey).value;
	var specimenIdentifier= document.getElementById(specimenIdentifierkey).value;
	var url ='ConsentVerification.do?operation=&pageOf=pageOfOrdering&status='+status+'&labelStatusId='+labelStatus+'&consentVerificationkey='+consentVerificationkey+'&showConsents=yes&specimenId='+specimenIdentifier;

	if(status!="No Consents")
	{
		window.open(url,'ConsentVerificationForm','height=300,width=800,scrollbars=1,resizable=1');
	}
}
</script>
</head>  
<body onload="tabToDisplay()">
<script type="text/javascript" src="jss/wz_tooltip.js"></script>

	<html:form action="<%=form_action%>">

<table width="100%" border="0" cellpadding="0" cellspacing="0" class="maintable">
  <tr>
    <td class="td_color_bfdcf3"><table border="0" cellpadding="0" cellspacing="0">
      <tr>
        <td class="td_table_head"><span class="wh_ar_b">
								<bean:message key="requestdetails.header" />
							</span></td>
        <td><img src="images/uIEnhancementImages/table_title_corner2.gif" alt="Page Title - Order" width="31" height="24" /></td>
      </tr>
    </table></td>
  </tr>
						  
			<tr>
    <td class="tablepadding"><table width="100%" border="0" cellpadding="0" cellspacing="0">
      <tr>
        <td width="90%" valign="bottom" class="td_tab_bg">&nbsp;</td>
      </tr>
    </table>
      <table width="100%" border="0" cellpadding="3" cellspacing="0" class="whitetable_bg">
        
        <tr>
          <td align="left" class=" grey_ar_s">&nbsp;<img src="images/uIEnhancementImages/star.gif" alt="Mandatory" width="6" height="6" hspace="0" vspace="0" />
						<bean:message key="commonRequiredField.message" />
					</td>
        </tr>
        <tr>
          <td align="left" class="tr_bg_blue1"><span class="blue_ar_b">&nbsp;<bean:message key="requestdetails.name" />
					</span></td>
        </tr>
        <tr>
          <td align="left" class="showhide"><table width="100%" border="0" cellspacing="0" cellpadding="3" >
              <tr>
						  <jsp:useBean id="requestDetailsForm" class="edu.wustl.catissuecore.actionForm.RequestDetailsForm" scope="request"/>	
				    <% 
				    	session.setAttribute("REQUEST_DETAILS_FORM",requestDetailsForm);%>
						<td width="17%" class="noneditable"><strong>
								<bean:message key='requestdetails.header.label.RequestorName'/>
							</strong></td>
			            <td class="noneditable">- <span class="link">
								<a class="view" href='mailto:<bean:write name='<%=  Constants.REQUEST_HEADER_OBJECT  %>'  property='email' scope='request' />' >
									<bean:write name="<%=  Constants.REQUEST_HEADER_OBJECT %>" property="requestedBy" scope="request"/> 
								</a>
							</span></td>
              </tr>
              <tr>
                <td class="noneditable"><strong>
								<bean:message key='requestlist.dataTabel.label.RequestDate'/>
							</strong></td>
                <td class="noneditable">- 
							<bean:write name="<%=  Constants.REQUEST_HEADER_OBJECT  %>" property="requestedDate" scope="request"/>
						</td>
              </tr>
              <tr>
                <td class="noneditable"><strong>
								<bean:message key='requestlist.dataTabel.DistributionProtocol.label'/>
							</strong></td>
                <td class="noneditable">-
							<bean:write name="<%=  Constants.REQUEST_HEADER_OBJECT  %>" property="distributionProtocol" scope="request"/>
						</td>
              </tr>
              <tr>
                <td class="noneditable"><strong>
								<bean:message key='requestdetails.header.label.Comments'/> 
								<bean:write name="<%=  Constants.REQUEST_HEADER_OBJECT  %>"  property="comments"  scope="request" />
							</strong></td>
                <td class="noneditable">&nbsp;</td>
              </tr>
          </table></td>
        </tr>
		 </table>
	     <table width="100%" border="0" cellpadding="0" cellspacing="0" class="whitetable_bg">
        <tr>
          <td align="left">
		<!-----------------------table for the tabs------------>
				<table width="100%" border="0" cellpadding="0" cellspacing="0">
              <tr>
                <td width="13%" style="border-bottom:1px solid #61a1e3" >&nbsp;</td>
                <td width="6%" valign="bottom" onclick="gotoSpecimenRequestTab()" id="specimenRequestTab" >
							<img src="images/uIEnhancementImages/tab_specimentR2_user.gif" alt="Specimen Request" width="124" height="20" />
						</td>
			            <td width="6%" valign="bottom" onClick="gotoArrayRequestTab()" id="arrayRequestTab" >
							<img src="images/uIEnhancementImages/tab_arrayR2_user1.gif" alt="Array Request" width="101" height="20" />
						</td>
			            <td valign="bottom" style="border-bottom:1px solid #61a1e3">&nbsp;</td>
              </tr>
          </table></td>
        </tr>

		  <tr >
          <td colspan="4"><table width="100%" border="0" cellpadding="3" cellspacing="0">
              <tr>
                <td colspan="3" align="left" class="showhide" style="border-bottom:1px solid #e3e2e2 "><table width="100%" border="0" cellspacing="0" cellpadding="4">
                    
					<tr>
						<td >
					<div id="specimenDataTab">
						<table border="0" width="100%" cellpadding="3" cellspacing="0">
							<tr>
                      <td colspan="11" align="right" valign="top" ><table width="100%" border="0" cellspacing="0" cellpadding="0">
                          <tr>
                            <td width="88%" align="right" nowrap >
											<img src="images/uIEnhancementImages/viewall_icon.gif" alt="View All" />
										  </td>
					                      <td width="12%" align="center" nowrap="nowrap" ><span class="link">
												<a href="javascript:showAllSpecimen('<%=count%>')" class="view" >
													<bean:message key="requestdetails.link.ViewAllConsents" />
							                    </a>
											  </span></td>
                          </tr>
                      </table></td>
                    </tr>
							<tr>
						  <% 
									if(requestDetailsList != null)
									{
									    session.setAttribute(Constants.REQUEST_DETAILS_LIST,requestDetailsList);
									 	int i = 0; 
										String rowStatusValue ="";
						 %>
					             <td colspan="5" align="center" valign="top" class="tableheading" width="40%">
									<strong>
										<bean:message key="requestdetails.header.RequestedSpecimenDetails" />
									</strong>
								 </td>
								 <!--<td width="3" class="tableheading">&nbsp;
				                 </td>-->
				                 <td width="8%" colspan="2" rowspan="2" align="left" valign="top" class="tableheading">
									<strong>
										<bean:message key='requestdetails.datatable.label.AvailableQty'/>
									</strong>
								 </td>
				                 <td width="15%" rowspan="2" valign="top" class="tableheading">
									<span class=" grey_ar_s">
										<img src="images/uIEnhancementImages/star.gif" alt="Mandatory Field" width="6" height="6" hspace="0" vspace="0" />
									</span>
									<strong>
										<bean:message key='requestdetails.datatable.label.AssignQty'/>
									</strong>
								</td>
				                <td width="11%" rowspan="2" valign="top" class="tableheading">
									<div>
										<strong>
											<bean:message key="consent.consentforspecimen"/>
											</br>
										</strong>	
									</div>
								</td>
				                <td width="16%" rowspan="2" valign="top" class="tableheading">
									<strong>
										<bean:message key='requestdetails.datatable.label.AssignStatus'/>
									</strong>
									</br>
					                <span class="black_new">
									     <html:select property="status" name="requestDetailsForm" styleClass="formFieldSized11" styleId="nextStatusId" size="1" onmouseover="showTip(this.id)" onmouseout="hideTip(this.id)" onchange="updateAllStatus()">
											<html:options collection="<%= Constants.REQUESTED_ITEMS_STATUS_LIST %>" labelProperty="name" property="value"/>		
									     </html:select>
								</td>	
				                <td rowspan="2" valign="top" class="tableheading" width="10%">
									<strong>
										<bean:message key="requestdetails.header.label.Comments" />
									</strong>
								</td>
				              </tr>
				              <tr>
								<td width="9%" class="subtd">
									<bean:message key='requestdetails.datatable.label.RequestItem'/>
								</td>
				                <td width="9%" class="subtd">
									<bean:message key='requestdetails.datatable.label.RequestFor'/>
								</td>
								<td width="10%" class="subtd" valign="top">
									<bean:message key="orderingSystem.tableheader.label.type" />
								</td>
				                <td width="9%" class="subtd" valign="top">
									<bean:message key='requestdetails.datatable.label.RequestedQty'/>
								</td>
				                <td width="3%" align="left" bgcolor="#d7d7d7" >&nbsp;
								</td>
				              </tr>
   <!----------------rows for the specimen request tab------------------>
							  <tbody id="tbody">	
				<%          int rows=0;
				%>
			<logic:iterate id="requestDetailsBeanObj" collection="<%= requestDetailsList%>" type="edu.wustl.catissuecore.bean.RequestDetailsBean">
				<%			String fontStyle="black_ar";
							rows++;
							if(rows<=count)
							if(rows%2 == 0)
							{
								fontStyle="tabletd1";
							}
							
						 	String requestFor = "value(RequestDetailsBean:"+i+"_requestFor)"; 
						 	String assignQty = "value(RequestDetailsBean:"+i+"_assignedQty)"; 
						 	String assignStatus = "value(RequestDetailsBean:"+i+"_assignedStatus)"; 	
							String description = "value(RequestDetailsBean:"+i+"_description)";
							String instanceOf = "value(RequestDetailsBean:"+i+"_instanceOf)";
							String orderItemId = "value(RequestDetailsBean:"+i+"_orderItemId)";
							String specimenIdInMap = "value(RequestDetailsBean:"+i+"_specimenId)";
							String consentVerificationkey = "value(RequestDetailsBean:"+i+"_consentVerificationkey)";
							String rowStatuskey = "value(RequestDetailsBean:"+i+"_rowStatuskey)";
							String labelStatus="labelStatus"+i;
							String requestedItem = "value(RequestDetailsBean:"+i+"_requestedItem)";
							String requestedQty = "value(RequestDetailsBean:"+i+"_requestedQty)";
							String availableQty = "value(RequestDetailsBean:"+i+"_availableQty)";
							String spClass = "value(RequestDetailsBean:"+i+"_className)";
							String spType = "value(RequestDetailsBean:"+i+"_type)";
							String distributedItemId = "value(RequestDetailsBean:"+i+"_distributedItemId)"; 
							String specimenList = "requestFor(RequestForDropDownList:"+i+")";
							String specimenCollGroupId = "value(RequestDetailsBean:"+i+"_specimenCollGroupId)";
							String actualSpecimenType = "value(RequestDetailsBean:"+i+"_actualSpecimenType)";
							String actualSpecimenClass = "value(RequestDetailsBean:"+i+"_actualSpecimenClass)";
							String specimenClickFunction = "showSpecimenDetails("+requestDetailsBeanObj.getSpecimenId()+")";
									//added for consent page:	
							String showNewConsentPageFunction = "showNewConsentPage("+requestDetailsBeanObj.getSpecimenId()+")";
							boolean disableRow = false;
							if((((String)(requestDetailsForm.getValue("RequestDetailsBean:"+i+"_assignedStatus"))).trim().equalsIgnoreCase(Constants.ORDER_REQUEST_STATUS_DISTRIBUTED))
							&& (!((String)(requestDetailsForm.getValue("RequestDetailsBean:"+i+"_distributedItemId"))).trim().equals("")))
							{
										disableRow=true;
										disabledStatus=i;
										rowStatusValue =	"disable";	
				%>
									
								<html:hidden name="requestDetailsForm" property="<%= assignStatus %>" />
								<html:hidden name="requestDetailsForm" property="<%= requestFor %>" />
								<html:hidden name="requestDetailsForm" property="<%= description %>" />
								<html:hidden name="requestDetailsForm" property="<%= assignQty %>" />
								<!--	<html:hidden name="requestDetailsForm" property="<%= consentVerificationkey %>"/>	-->
				<%
							}
							else{ rowStatusValue =	"enable";
							}
								 	//Added By Ramya.Construct corresponding rowids for request row expansion purpose.								 	
							String data = "data" + i;
							String switchText = "switch" + i;
							//Added By Ramya.Construct select element ids for corresponding rows.
									//This is to update all rows' status in one shot.
							String select = "select_" +	i;
									//This is to update available qty for the specimen selected from requestFor drop down.
							String updateAvaiQty = "avaiQty" + i;
							String requestForId = "requestFor" + i;
							String onChangeValueForRequestFor = "updateQuantity('"+ requestForId  +"')";
							if(((requestDetailsForm.getValue("RequestDetailsBean:"+i+"_specimenId"))) != null && !((String)(requestDetailsForm.getValue("RequestDetailsBean:"+i+"_specimenId"))).equals(""))
							{
				%>
								<html:hidden name="requestDetailsForm" property="<%= specimenIdInMap %>" />
				<%			}
							else
							{
				%>
								<html:hidden name="requestDetailsForm" property="<%= specimenCollGroupId %>" />
				<%			}
			    %>	<!-- Html hidden variables for all static fields -->	 
								
								 <html:hidden name="requestDetailsForm" property="<%= requestedItem %>" />	
								 <html:hidden name="requestDetailsForm" property="<%= requestedQty %>" />	
								 <html:hidden name="requestDetailsForm" property="<%= availableQty %>" />	
								 <html:hidden name="requestDetailsForm" property="<%= spClass %>" />	
								 <html:hidden name="requestDetailsForm" property="<%= spType %>" />	
								 <html:hidden name="requestDetailsForm" property="<%= actualSpecimenClass %>" />	
								 <html:hidden name="requestDetailsForm" property="<%= actualSpecimenType %>" />	

								<tr>
									<td class="<%=fontStyle%>" >
					<%													                                                     if(((String)(requestDetailsForm.getValue("RequestDetailsBean:"+i+"_instanceOf"))).trim(            ).equalsIgnoreCase("Derived"))
								{
					%>											
										<img src="images\Distribution.GIF" border="0"/>

									 		<!-- bean:write name="requestDetailsBeanObj" property="requestedItem" /-->
			 		<%			}
								else																					if(((String)(requestDetailsForm.getValue("RequestDetailsBean:"+i+"_instanceOf"))			).trim().equalsIgnoreCase("DerivedPathological")
										|| ((String)(requestDetailsForm.getValue("RequestDetailsBean:"+i+"_instanceOf"))).trim().equalsIgnoreCase("Pathological"))
									{
					%>
										<img src="images\Participant.GIF" border="0"/>
					<%				}
										String toolTipTypeClass = "Class:"+((String)(requestDetailsForm.getValue("RequestDetailsBean:"+i+"_actualSpecimenClass")))+", Type:"+((String)(requestDetailsForm.getValue("RequestDetailsBean:"+i+"_actualSpecimenType"))); %>
									 	<span title="<%= toolTipTypeClass %>">
									 		<%--Bug :6010- Hide link to Specimen Label in case of Pathological case report. 
									 		    Modified by:Falguni Sachde
									 		  --%>
					<%	if(((String)(requestDetailsForm.getValue("RequestDetailsBean:"+i+"_instanceOf"))).trim().equalsIgnoreCase("DerivedPathological")
												|| ((String)(requestDetailsForm.getValue("RequestDetailsBean:"+i+"_instanceOf"))).trim().equalsIgnoreCase("Pathological")) 
									{
					%>
												
											<bean:write name="requestDetailsForm" property="<%= requestedItem%>" />									 	
					<%
									}
									else
									{
					%>
										<html:link href="#" styleClass="view" styleId="label" onclick="<%=specimenClickFunction%>">
									 		<bean:write name="requestDetailsForm" property="<%= requestedItem %>" />	
										</html:link>
					<%
									}
					%>
							 		</span>
		  					 	</td>
				 	<%
						 		if(((String)(requestDetailsForm.getValue("RequestDetailsBean:"+i+"_instanceOf"))).trim().equalsIgnoreCase("Existing"))
						 		{
						 			disableRow=true;
						 		}
					%>
									 	<!-- Added By Ramya for Tree View -->
					   		 	<td class="<%=fontStyle%>" >
					<%																										if(!((String)(requestDetailsForm.getValue("RequestDetailsBean:"+i+"_instanceOf"))).trim(				).equalsIgnoreCase("Existing"))
							{
					%>
									<html:select property="<%= requestFor %>" name="requestDetailsForm" styleClass="formFieldSized6" styleId="<%= requestForId %>" 					 	onmouseover="showTip(this.id)" onmouseout="hideTip(this.id)" disabled="<%= disableRow%>" onchange="<%= onChangeValueForRequestFor %>">
										<html:optionsCollection property="<%=specimenList%>" name="requestDetailsForm" label="name" value="value"/>
									 				<!-- html:options collection="<%=Constants.REQUEST_FOR_LIST%>" labelProperty="name" property="value"/-->						
							 		</html:select>
								 	<bean:define id="specimenType" name="requestDetailsForm" property="<%=spType %>" type="java.lang.String"/>
									<bean:define id="specimenClass" name="requestDetailsForm" property="<%=spClass %>" type="java.lang.String"/>
									
			 		<%
								 	String url ="";
					 			if(((requestDetailsForm.getValue("RequestDetailsBean:"+i+"_specimenId"))) != null && !((String)(requestDetailsForm.getValue("RequestDetailsBean:"+i+"_specimenId"))).equals(""))
								{
						 				String specimenObjId = ((String)(requestDetailsForm.getValue("RequestDetailsBean:"+i+"_specimenId")));
										url = "ShowFramedPage.do?pageOf=pageOfSpecimenTree&" + Constants.PROPERTY_NAME + "=" + requestFor + "&" + Constants.SPECIMEN_TYPE + "=" + specimenType + "&" + Constants.SPECIMEN_CLASS + "=" + specimenClass + "&" + Constants.SPECIMEN_TREE_SPECIMEN_ID + "=" + specimenObjId;
													//session.setAttribute(Constants.SPECIMEN_TREE_SPECIMEN_ID,specimenObjId);
					%>
					<%
								}
								else
								{
										String specimenCollGrpId = ((String)(requestDetailsForm.getValue("RequestDetailsBean:"+i+"_specimenCollGroupId")));
										url = "ShowFramedPage.do?pageOf=pageOfSpecimenTree&" + Constants.PROPERTY_NAME + "=" + requestFor + "&" + Constants.SPECIMEN_TYPE + "=" + specimenType + "&" + Constants.SPECIMEN_CLASS + "=" + specimenClass + "&" + Constants.SPECIMEN_TREE_SPECCOLLGRP_ID + "=" + specimenCollGrpId;
									
					%>
	 				<%
								}
										String appletVar = "";
										if(disableRow == false)
											appletVar = "javascript:NewWindow('"+url+"','name','375','330','yes');return false";
					%>
											<a href="#" class="fontStyle" onclick="<%= appletVar %>">
												<img src="images\uIEnhancementImages\ic_cl_diag.gif" border="0" height="16" width="16" alt="Clinical Diagnosis" title="<%= ApplicationProperties.getValue("requestdetails.tooltip.specimenTreeTooltip") %>" />
											</a>
											<!-- Displaying add new link if specimen does not exist -->
				<%			if(((requestDetailsForm.getRequestFor("RequestForDropDownList:"+i)) == null) ||						(((List)(requestDetailsForm.getRequestFor("RequestForDropDownList:"+i))).size() == 0))
							{
									if((((String)(requestDetailsForm.getValue("RequestDetailsBean:"+i+"_instanceOf"))).trim().equalsIgnoreCase("DerivedPathological")) || (((String)(requestDetailsForm.getValue("RequestDetailsBean:"+i+"_instanceOf"))).trim().equalsIgnoreCase("Pathological")))
							 		{												 			
				%>
										 <a href="createSpecimenFromOrder.do?rowNumber=<%=i%>">
										 	<bean:message key="orderingSystem.label.create" />
										</a> 
				<%					}
									else
									{
				%>
										<a href="createDerivedSpecimen.do?rowNumber=<%=i%>">
														 <!-- OrderingSystemAddNew.do?addNewForwardTo=deriveSpecimen&forwardTo=orderDetails&addNewFor=specimenId -->
											<bean:message key="orderingSystem.label.create" />
										</a> 
				<%					}
							}														
						}
						else
						{
				%>
							    		<span title="<%= toolTipTypeClass %>">
									 		<bean:write name="requestDetailsForm" property="<%= requestedItem %>" />	
									 	</span>
				<%		
						}
				%> 
								 	</td>
								 	<td class="<%=fontStyle%>" >
										<bean:write name="requestDetailsForm" property="<%= spType %>" />
								 	</td>
				<%
					 	if((((String)(requestDetailsForm.getValue("RequestDetailsBean:"+i+"_instanceOf"))).trim().equalsIgnoreCase("Existing")
					 		|| ((String)(requestDetailsForm.getValue("RequestDetailsBean:"+i+"_instanceOf"))).trim().equalsIgnoreCase("Pathological"))
					 		&& (((String)(requestDetailsForm.getValue("RequestDetailsBean:"+i+"_distributedItemId"))).trim().equals("")))
				 		{
				 			disableRow=false;												
				 		}
					 		String className = ((String)(requestDetailsForm.getValue("RequestDetailsBean:"+i+"_className")));
					 		String type = ((String)(requestDetailsForm.getValue("RequestDetailsBean:"+i+"_type")));
			 	%>
								 	<td class="<%=fontStyle%>" >
							 		<!-- bean:write name="requestDetailsBeanObj" property="requestedQty" /-->		
								 		<bean:write name="requestDetailsForm" property="<%= requestedQty %>" />
									 		<span>		
												<script>
													var v= getUnit('<%= className %>','<%= type %>');
													document.write(v);
												</script>
											</span>	
									 	</td>
										<td class="<%=fontStyle%>">&nbsp;</td>
									 	<td class="<%=fontStyle%>" align="left">
											<div id="<%= updateAvaiQty %>" >
										 		<bean:write name="requestDetailsForm" property="<%= availableQty %>" />
												
										 	</div></td>
											<td class="<%=fontStyle%>">
									 		<span>
												<script>
													var v= getUnit('<%= className %>','<%= type %>');
													document.write(v);
												</script>
											</span>	
									 	</td>
									 	<td class="<%=fontStyle%>" > 										 		
									 		<html:text name="requestDetailsForm" styleClass="black_ar" maxlength="3" size="3" styleId="<%=assignQty%>" property="<%=assignQty %>" disabled="<%= disableRow %>" style="text-align:right" />
									 		<span>		
												<script>
													var v= getUnit('<%= className %>','<%= type %>');
													document.write(v);
												</script>
											</span>	
									 	</td>

			   <%
						String consentVerificationStatus=((String)(requestDetailsForm.getValue("value(RequestDetailsBean:"+i+"_consentVerificationkey)")));
						String specimenIdValue=((String)(requestDetailsForm.getValue("value(RequestDetailsBean:"+i+"_specimenId)")));
									
				%>
					
							
										<td class="<%=fontStyle%>"  > 
											<html:hidden property="<%=specimenIdInMap%>" styleId="<%=specimenIdInMap%>"  value="<%=specimenIdValue%>"/>
											<html:hidden property="<%=rowStatuskey%>" styleId="<%=rowStatuskey%>"  value="<%=rowStatusValue%>"/>		

											
				<%																										if(((String)(requestDetailsForm.getValue("RequestDetailsBean:"+i+"_instanceOf"))).trim().equalsIgnoreCase("Derived") ||
							((String)(requestDetailsForm.getValue("RequestDetailsBean:"+i+"_instanceOf"))).trim().equalsIgnoreCase("Pathological") ||
							((String)(requestDetailsForm.getValue("RequestDetailsBean:"+i+"_instanceOf"))).trim().equalsIgnoreCase("DerivedPathological"))
						{
					
				%>
														
											<%=Constants.NO_CONSENTS%>
											<html:hidden property="<%=consentVerificationkey%>" styleId="<%=consentVerificationkey%>"  value="<%=Constants.NO_CONSENTS%>"/>
							
				<%		}
				%>

				<%																											if(((String)(requestDetailsForm.getValue("RequestDetailsBean:"+i+"_instanceOf"))).trim().equalsIgnoreCase("Existing"))
						{
				%>

				<%
							if(!disableRow)
							{
				%>	
						<logic:equal name="requestDetailsForm" property="<%=consentVerificationkey%>" value="<%=Constants.NO_CONSENTS%>">
											<%=Constants.NO_CONSENTS%>
											<html:hidden property="<%=consentVerificationkey%>" styleId="<%=consentVerificationkey%>"  value="<%=Constants.NO_CONSENTS%>"/>
						</logic:equal>
						<logic:notEqual name="requestDetailsForm" property="<%=consentVerificationkey%>" value="<%=Constants.NO_CONSENTS%>">
											<a  id="<%=labelStatus%>" href="javascript:showNewConsentPage('<%=specimenIdInMap%>','<%=labelStatus%>','<%=consentVerificationkey%>')">
						<logic:notEmpty name="requestDetailsForm" property="<%=consentVerificationkey%>">
												<bean:write name="requestDetailsForm" property="<%=consentVerificationkey%>"/>
						</logic:notEmpty>
						<logic:empty name="requestDetailsForm" property="<%=consentVerificationkey%>">
												<%=Constants.VIEW_CONSENTS %>
						</logic:empty>
						<logic:notEmpty name="requestDetailsForm" property="<%=consentVerificationkey%>">
												<html:hidden property="<%=consentVerificationkey%>" styleId="<%=consentVerificationkey%>"  value="<%=consentVerificationStatus%>"/>
						</logic:notEmpty>
						<logic:empty name="requestDetailsForm" property="<%=consentVerificationkey%>">
												<html:hidden property="<%=consentVerificationkey%>" styleId="<%=consentVerificationkey%>"  value="<%=Constants.VIEW_CONSENTS %>"/>
						</logic:empty>
											</a>
						</logic:notEqual>
				<%
						}
						else
						{ 
				%>
											<%=Constants.VERIFIED%>
											<html:hidden property="<%=consentVerificationkey%>" styleId="<%=consentVerificationkey%>"  value="<%=Constants.VERIFIED%>"/>
				<%
						}
				%>
										</td>
				<%		}
				%>
									 	
									 	<td class="<%=fontStyle%>" >									 		<span class="black_new">
									 		<html:select property="<%=assignStatus %>" name="requestDetailsForm" styleClass="formFieldSized11" styleId="<%=select%>"  
					 								onmouseover="showTip(this.id)" onmouseout="hideTip(this.id)" disabled="<%= disableRow %>">
					 								<html:options collection="<%=Constants.ITEM_STATUS_LIST%>" labelProperty="name" property="value"/>							
									 		</html:select>
											</span>
									 	</td>
										<td class="<%=fontStyle%>" >												 
											<html:textarea styleId="description" styleClass="black_ar"  property="<%= description%>" cols='20' rows='2' disabled="<%= disableRow %>"/>
										</td>
									 </tr>

								  <!-- Block for row expansion ends here -->
								  <!--  Flag for instanceOf  -->
	
										<html:hidden name="requestDetailsForm" property="<%= instanceOf %>" />
										<html:hidden name="requestDetailsForm" property="<%= orderItemId %>" />
										<html:hidden name="requestDetailsForm" property="<%= distributedItemId %>" />
									 <% i++; %>
					 </logic:iterate>
				<%	 } //End Outer IF 
				%>
						</table>
						
						</div>

						<div id="arrayDataTable" style="display:none" >
		<%-- Include ArrayRequest page for ArrayRequests tab --%>
						<%@ include file="/pages/content/orderingsystem/ArrayRequests.jsp" %>
						</div>
						
					</td>
				</tr>
				</table>
				</td>
				</tr>
				<tr>
 					<td valign="top" class="black_ar">&nbsp;<br />
                  &nbsp;
 						<bean:message key="requestdetails.header.label.Comments" />
	 				</td>
 					<td valign="top" class="black_ar"><br />
 						<html:textarea name="requestDetailsForm" styleClass="black_ar" cols="90" rows="3" property="administratorComments"  />
		 			</td>
					<td valign="top" class="black_ar"></td>
              </tr>
              <tr >
                <td valign="top" class="black_ar">&nbsp;
						<bean:message key='requestlist.dataTabel.label.Site'/> 
 					</td>
					<td valign="top" class="black_new">
						<html:select property="site" name="requestDetailsForm" styleClass="formFieldSized12" styleId="siteId" size="1" onmouseover="showTip(this.id)" onmouseout="hideTip(this.id)">
							<html:options collection="<%= Constants.SITE_LIST_OBJECT  %>" labelProperty="name" property="value"/>		
						</html:select> 						
					</td>
					<td valign="top" class="black_ar"></td>
        				<html:hidden name="requestDetailsForm" property="id" />
		<%							
			  String operationUpdate = "update";
			  String distributionProtocol = ((RequestViewBean)request.getAttribute(Constants.REQUEST_HEADER_OBJECT)).getDistributionProtocolId(); 
		%>
						<html:hidden name="requestDetailsForm" property="operation" value="<%= operationUpdate %>"/>
						<html:hidden name="requestDetailsForm" property="distributionProtocolId" value="<%= distributionProtocol %>"/>							
						<html:hidden name="requestDetailsForm" property="tabIndex" styleId="tabIndexId"/>			
						<html:hidden name="requestDetailsForm" property="mailNotification" styleId="mailNotification"/>							
				</tr>
          </table></td>
        </tr>
        <tr>
          <td class="bottomtd"></td>
        </tr>
        <tr>
          <td class="buttonbg" style="padding:6px;">
					<input type="button" class="blue_ar_b" value="Submit" onclick="submitPage()" accesskey="Enter">
					<input type="button" class="blue_ar_c" value="Submit And Notify" onclick="submitAndNotify()">
					 &nbsp;|&nbsp; 
						
							<html:link page="/ManageAdministrativeData.do" styleClass="cancellink">
								<bean:message key="orderingsystem.button.cancel" />
				            </html:link>
						
					</td>
				</tr>
      </table>
    </td>
  </tr>
</table>
   <!-- main table ends here -->
</html:form>
</body>

<!----------------------------------------------->	