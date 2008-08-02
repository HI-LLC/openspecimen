package edu.wustl.catissuecore.action;

import java.util.HashMap;
import java.util.Map;
import java.util.Stack;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.struts.action.Action;
import org.apache.struts.action.ActionError;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import edu.wustl.catissuecore.bizlogic.BizLogicFactory;
import edu.wustl.catissuecore.domain.User;
import edu.wustl.catissuecore.dto.UserDTO;
import edu.wustl.catissuecore.multiRepository.bean.SiteUserRolePrivilegeBean;
import edu.wustl.catissuecore.util.global.Constants;
import edu.wustl.common.actionForm.AbstractActionForm;
import edu.wustl.common.beans.AddNewSessionDataBean;
import edu.wustl.common.beans.SessionDataBean;
import edu.wustl.common.bizlogic.IBizLogic;
import edu.wustl.common.bizlogic.QueryBizLogic;
import edu.wustl.common.domain.AbstractDomainObject;
import edu.wustl.common.exception.AssignDataException;
import edu.wustl.common.exception.BizLogicException;
import edu.wustl.common.factory.AbstractDomainObjectFactory;
import edu.wustl.common.factory.AbstractForwardToFactory;
import edu.wustl.common.factory.MasterFactory;
import edu.wustl.common.security.exceptions.UserNotAuthorizedException;
import edu.wustl.common.util.AbstractForwardToProcessor;
import edu.wustl.common.util.Utility;
import edu.wustl.common.util.dbManager.HibernateMetaData;
import edu.wustl.common.util.global.ApplicationProperties;
import edu.wustl.common.util.global.Validator;
import edu.wustl.common.util.logger.Logger;


public class SubmitUserAction extends Action
{
	 String target = null;
	 User user = null;
	 ActionMessages messages = null;  
	    
	public ActionForward execute(ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response) throws AssignDataException
    {
		AbstractDomainObjectFactory abstractDomainObjectFactory=getAbstractDomainObjectFactory();
		AbstractActionForm form1 = (AbstractActionForm)form;
        user = (User) abstractDomainObjectFactory.getDomainObject(form1.getFormId(), form1);
        AbstractActionForm abstractForm = (AbstractActionForm)form;
        String objectName = abstractDomainObjectFactory.getDomainObjectName(abstractForm.getFormId());
        //UserBizLogic bizLogic = (UserBizLogic) BizLogicFactory.getInstance().getBizLogic(Constants.USER_FORM_ID);
        HttpSession session = request.getSession();
        //SessionDataBean sessionDataBean = (SessionDataBean) session.getAttribute(Constants.SESSION_DATA);
        //bizLogic.insert(user, sessionDataBean, Constants.HIBERNATE_DAO);
        target = new String(Constants.SUCCESS);
        AbstractDomainObject abstractDomain = (AbstractDomainObject) user;
        UserDTO userDTO = getUserDTO(user, session);
		try 
		{
			insertUser(userDTO, request.getSession());

//		Attributes to decide AddNew action
        String submittedFor = (String) request.getParameter(Constants.SUBMITTED_FOR);
        request.setAttribute(Constants.SYSTEM_IDENTIFIER, user.getId());
        Logger.out.debug("Checking parameter SubmittedFor in CommonAddEditAction--->"+request.getParameter(Constants.SUBMITTED_FOR));
        Logger.out.debug("SubmittedFor attribute of Form-Bean received---->"+abstractForm.getSubmittedFor());
        IBizLogic queryBizLogic = BizLogicFactory.getInstance().getBizLogic(Constants.QUERY_INTERFACE_ID);
        messages = new ActionMessages();
        
        addMessage(messages, abstractDomain, "add", (QueryBizLogic)queryBizLogic, objectName);
       
        if( (submittedFor !=null)&& (submittedFor.equals("AddNew")) )
        {
            Logger.out.debug("SubmittedFor is AddNew in CommonAddEditAction...................");
            
            
            Stack formBeanStack = (Stack)session.getAttribute(Constants.FORM_BEAN_STACK);
            
	        if(formBeanStack !=null)
	        {
	            
	            AddNewSessionDataBean addNewSessionDataBean = (AddNewSessionDataBean)formBeanStack.pop();
	            
	            if(addNewSessionDataBean != null)
	            {
    	            AbstractActionForm sessionFormBean = addNewSessionDataBean.getAbstractActionForm();
    	            
    	            String forwardTo = addNewSessionDataBean.getForwardTo();
    	            Logger.out.debug("forwardTo in CommonAddEditAction--------->"+forwardTo);
    	            sessionFormBean.setAddNewObjectIdentifier(addNewSessionDataBean.getAddNewFor(), abstractDomain.getId());
    	            sessionFormBean.setMutable(false);
    	            if(formBeanStack.isEmpty())
    	            {
    	                session.removeAttribute(Constants.FORM_BEAN_STACK);
    	                request.setAttribute(Constants.SUBMITTED_FOR, "Default");
    	                Logger.out.debug("SubmittedFor set as Default in CommonAddEditAction===========");
    	                
    	                Logger.out.debug("cleaning FormBeanStack from session*************");
    	            }
    	            else
    	            {
    	                request.setAttribute(Constants.SUBMITTED_FOR, "AddNew");
    	            }
    	            String formBeanName = Utility.getFormBeanName(sessionFormBean);
    	            request.setAttribute(formBeanName, sessionFormBean);
    	            
    	            Logger.out.debug("InitiliazeAction operation=========>"+sessionFormBean.getOperation());
    	            
    	            if (messages != null)
                    {
                        saveMessages(request,messages);
                    }
                    String statusMessageKey = String.valueOf(abstractForm.getFormId() +
        					"."+String.valueOf(abstractForm.isAddOperation()));
                    request.setAttribute(Constants.STATUS_MESSAGE_KEY,statusMessageKey);
    	            if( (sessionFormBean.getOperation().equals("edit") ) )
    	            {
    	                Logger.out.debug("Edit object Identifier while AddNew is from Edit operation==>"+sessionFormBean.getId());
    	                ActionForward editForward = new ActionForward();
    	                
    	                String addPath = (mapping.findForward(forwardTo)).getPath();
    	                Logger.out.debug("Operation before edit==========>"+addPath);
    	                
    	                String editPath = addPath.replaceFirst("operation=add","operation=edit");
    	                Logger.out.debug("Operation edited=============>"+editPath);
                   		editForward.setPath(editPath);
                   		
                   		return editForward;
    	            }   
    	            return (mapping.findForward(forwardTo));
	            }
	            else
	            {
	                target = new String(Constants.FAILURE);
                    
                    ActionErrors errors = new ActionErrors();
                	ActionError error = new ActionError("errors.item.unknown",
                	        				AbstractDomainObject.parseClassName(objectName));
                	errors.add(ActionErrors.GLOBAL_ERROR,error);
                	saveErrors(request,errors);
	            }
	        }
        }
        else if( (submittedFor !=null)&& (submittedFor.equals("ForwardTo")) )
        {
            Logger.out.debug("SubmittedFor is ForwardTo in CommonAddEditAction...................");
            request.setAttribute(Constants.SUBMITTED_FOR, "Default");
            request.setAttribute("forwardToHashMap", generateForwardToHashMap(abstractForm, abstractDomain));
        }
        if(abstractForm.getForwardTo()!= null && abstractForm.getForwardTo().trim().length()>0  )
       {
       		String forwardTo = abstractForm.getForwardTo(); 
       		Logger.out.debug("ForwardTo in Add :-- : "+ forwardTo);
       		target = forwardTo;
       }
       request.setAttribute("forwardToPrintMap",generateForwardToPrintMap(abstractForm, abstractDomain));
       if (messages != null)
       {
           saveMessages(request,messages);
       }
       String statusMessageKey = String.valueOf(abstractForm.getFormId() +
				"."+String.valueOf(abstractForm.isAddOperation()));
       request.setAttribute(Constants.STATUS_MESSAGE_KEY, statusMessageKey);
		}
		catch (UserNotAuthorizedException excp) 
		{
			ActionErrors errors = new ActionErrors();
            SessionDataBean sessionDataBean = (SessionDataBean) request.getSession().getAttribute(Constants.SESSION_DATA);
            String userName = "";
        	
            if(sessionDataBean != null)
        	{
        	    userName = sessionDataBean.getUserName();
        	}
            
        	ActionError error = new ActionError("access.addedit.object.denied", userName, abstractDomain.getClass().getName());
        	errors.add(ActionErrors.GLOBAL_ERROR, error);
        	saveErrors(request, errors);
        	target = Constants.FAILURE;
            Logger.out.error(excp.getMessage(), excp);
		}
		catch (BizLogicException excp)
        {
        	ActionErrors errors = new ActionErrors();
        	ActionError error = new ActionError("errors.item",excp.getMessage());
        	errors.add(ActionErrors.GLOBAL_ERROR,error);
        	saveErrors(request,errors);
            target = new String(Constants.FAILURE);
            
            Logger.out.error(excp.getMessage(), excp);
        }
		return mapping.findForward(target);
	}
	
    /**
     * This method generates HashMap of data required to be forwarded if Form is submitted for Print request
     * @param abstractForm	Form submitted
     * @param abstractDomain	DomainObject Added/Edited
     * @return	HashMap of data required to be forwarded
     */
    private HashMap generateForwardToPrintMap(AbstractActionForm abstractForm, AbstractDomainObject abstractDomain)throws BizLogicException
    {
        HashMap forwardToPrintMap = null;
        AbstractForwardToProcessor forwardToProcessor=AbstractForwardToFactory.getForwardToProcessor(
				ApplicationProperties.getValue("app.forwardToFactory"),
				"getForwardToPrintProcessor");
        forwardToPrintMap = (HashMap)forwardToProcessor.populateForwardToData(abstractForm,abstractDomain);
        return forwardToPrintMap;
    }

	    private HashMap generateForwardToHashMap(AbstractActionForm abstractForm, AbstractDomainObject abstractDomain)throws BizLogicException
	    {
	        HashMap forwardToHashMap;
	        AbstractForwardToProcessor forwardToProcessor=AbstractForwardToFactory.getForwardToProcessor(
						ApplicationProperties.getValue("app.forwardToFactory"),
						"getForwardToProcessor");
	        forwardToHashMap = (HashMap)forwardToProcessor.populateForwardToData(abstractForm,abstractDomain);
	        return forwardToHashMap;
	    }

	public AbstractDomainObjectFactory getAbstractDomainObjectFactory() 
	{	
		return (AbstractDomainObjectFactory) MasterFactory.getFactory(ApplicationProperties.getValue("app.domainObjectFactory"));
	}
	
	/**
     * 
     * @param user
     * @param session
     * @return
     */
    private UserDTO getUserDTO(User user, HttpSession session)
	{
    	UserDTO userDTO = new UserDTO();
		Map<String, SiteUserRolePrivilegeBean> userRowIdBeanMap  = (Map<String, SiteUserRolePrivilegeBean>)session.getAttribute("rowIdBeanMapForUserPage");
		userDTO.setUser(user);
		userDTO.setUserRowIdBeanMap(userRowIdBeanMap);
		return userDTO;
	}
    
    
    /**
     * 
     * @param userDTO
     * @param session
     * @throws BizLogicException
     * @throws UserNotAuthorizedException
     */
    private void insertUser(UserDTO userDTO, HttpSession session)
	throws BizLogicException, UserNotAuthorizedException 
	{
    	IBizLogic bizLogic =BizLogicFactory.getInstance().getBizLogic(Constants.USER_FORM_ID);
		SessionDataBean sessionDataBean = (SessionDataBean) session.getAttribute(Constants.SESSION_DATA);		
		bizLogic.insert(userDTO, sessionDataBean, Constants.HIBERNATE_DAO);
	}
    
    /**
     * This method will add the success message into ActionMessages object
     * @param messages ActionMessages
     * @param abstractDomain AbstractDomainObject
     * @param addoredit String
     * @param queryBizLogic QueryBizLogic
     * @param objectName String
     */
    private void addMessage(ActionMessages messages, AbstractDomainObject abstractDomain, String addoredit, QueryBizLogic queryBizLogic, String objectName) {
    	String message = abstractDomain.getMessageLabel();
    	Validator validator = new Validator();
    	boolean isEmpty = validator.isEmpty(message);
    	String displayName = null;
    	try
		{
    		displayName = queryBizLogic.getDisplayNamebyTableName(HibernateMetaData.getTableName(abstractDomain.getClass()));
		} 
    	catch(Exception excp)
		{
    		displayName = AbstractDomainObject.parseClassName(objectName);
    		Logger.out.error(excp.getMessage(), excp);
		}
    	
    	if (!isEmpty)    	{
        	messages.add(ActionErrors.GLOBAL_MESSAGE,new ActionMessage("object." + addoredit + ".success", displayName, message));
    	}
    	else
    	{
    		messages.add(ActionErrors.GLOBAL_MESSAGE,new ActionMessage("object." + addoredit + ".successOnly", displayName));
    	} 
    }

}
