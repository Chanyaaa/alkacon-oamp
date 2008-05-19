<%@page buffer="none" session="false" import="org.opencms.i18n.*,com.alkacon.opencms.comments.*, com.alkacon.opencms.formgenerator.*, java.util.*" %><%

// initialize the form handler
CmsCommentFormHandler cms = new CmsCommentFormHandler(pageContext, request, response, new CmsCommentsAccess(pageContext, request, response).getConfig().getConfigUri());
cms.getRequestContext().setUri(request.getParameter(CmsCommentsAccess.PARAM_URI));
cms.init(request, cms.getCommentFormConfiguration().getConfigUri());

// get the localized messages to create the form
CmsMessages messages = cms.getMessages();

boolean showForm = cms.showForm();
if (!showForm) {
	// form has been submitted with correct values
	// try to send a notification email with the submitted form field values
	if (cms.sendData()) {
	    // successfully submitted
            out.print("ok");
	} else {
	    // problem while submitting
	    out.println("<h3>" + messages.key("form.error.mail.headline") + "</h3>");
	    out.println("<p>" + messages.key("form.error.mail.text") + "</p>");
	    out.println("<!-- Error description: " + cms.getErrors().get("sendmail") + "//-->");
	}
	return;
} 

// get the configured form elements
CmsCommentForm formConfiguration = cms.getCommentFormConfiguration();
List fields = formConfiguration.getFields();

// show form text 
out.print(formConfiguration.getFormText());

// show global error message if validation failed
if (cms.hasValidationErrors()) {
	out.print("<p>");
	out.print(messages.key("form.html.label.error.start"));
	out.print(messages.key("form.error.message"));
	out.print(messages.key("form.html.label.error.end"));
	out.println("</p>");
}
%>
<!-- create the form head  -->
<form id="fid" name="commentform" <%= formConfiguration.getFormAttributes() %>>
<!-- Hidden form fields:  -->
<input type="hidden" name="<%= CmsFormHandler.PARAM_FORMACTION %>"  id="<%= CmsFormHandler.PARAM_FORMACTION %>" value="<%= CmsFormHandler.ACTION_SUBMIT %>"/>
<input type="hidden" name="<%= CmsCommentsAccess.PARAM_URI %>" value="${param.cmturi}" />
<input type="hidden" name="__locale" value="${param.__locale}" />
<%= messages.key("form.html.start") %>
<%
// create the html output to display the form fields
int pos=0;
int place=0;
for( int i = 0, n = fields.size(); i < n; i++) {
	// loop through all form input fields 
	I_CmsField field = (I_CmsField)fields.get(i);
	
	if(i==n-1)place=1; //the last one must close the tr
	field.setPlaceholder(place);
	field.setPosition(pos);
	String errorMessage = (String)cms.getErrors().get(field.getName());
	
	out.println(field.buildHtml(cms, messages, errorMessage, formConfiguration.isShowMandatory()));
	pos=field.getPosition();
	place=field.getPlaceholder();
}

// create the form foot 
if (formConfiguration.hasMandatoryFields() && formConfiguration.isShowMandatory()) {
	%><%= messages.key("form.html.row.start") %>
	<%= messages.key("form.html.button.start") %><%= messages.key("form.message.mandatory") %><%= messages.key("form.html.button.end") %>
	<%= messages.key("form.html.row.end") %>
	<%
}
%>
<%= messages.key("form.html.end") %>
</form>
<%
// show form footer text
out.print(formConfiguration.getFormFooterText());
%>