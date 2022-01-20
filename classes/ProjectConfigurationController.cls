/**
 * Controller class for Project Configurations on community
 */
public without sharing class ProjectConfigurationController {

	/**
	 * Method to fetch the active customer projects for active customer project team member
	 */
	@AuraEnabled(cacheable=true)
	public static CommunityWrapper.ResponseWrap getUserProjects(){
		try {
			Id currentUserContactId = ( CommunityUtils.getLoginUser() != null ) ? CommunityUtils.getLoginUser().ContactId : null;
			List<CommunityWrapper.PicklistEntry> userProjectOptions = new List<CommunityWrapper.PicklistEntry>();
			Set<Id> userProjectsId = new Set<Id>();
			List<Project_Team_Member__c> userProjectTeamMembers = [SELECT Customer_Project__c, Customer_Project__r.Name FROM Project_Team_Member__c
																   WHERE Contact__c != NULL AND Contact__c = :currentUserContactId
																   AND Customer_Project__c != NULL
																   AND IsActive__c = TRUE AND Customer_Project__r.IsActive__c = TRUE ORDER BY Customer_Project__r.Name];
			for(Project_Team_Member__c projectTeamMember : userProjectTeamMembers) {
				if(!userProjectsId.Contains(projectTeamMember.Customer_Project__c)) {
					userProjectOptions.add(new CommunityWrapper.PicklistEntry(projectTeamMember.Customer_Project__r.Name, projectTeamMember.Customer_Project__c));
					userProjectsId.add(projectTeamMember.Customer_Project__c);
				}
			}
			return new CommunityWrapper.ResponseWrap(FALSE, NULL, userProjectOptions);
		} catch (Exception ex) {
			return new CommunityWrapper.ResponseWrap(TRUE, ex.getMessage());
		}
	}

	/**
	 * Method to fetch the permissions for configuration of active customer project for a active customer project team member
	 */
	@AuraEnabled(cacheable=true)
	public static CommunityWrapper.ResponseWrap getUserProjectDetailsAndPermissions(String userProjectId) {
		try {
			Id currentUserContactId = ( CommunityUtils.getLoginUser() != null ) ? CommunityUtils.getLoginUser().ContactId : null;
			CommunityWrapper.UserProjectDetails userProjectDetails;
			List<Project_Team_Member__c> userProjectPermissions = [SELECT Id, Customer_Project__r.Id, Customer_Project__r.Name, Customer_Project__r.Account__r.Name,
																   Customer_Project__r.Number_of_Team_Members__c, Customer_Project__r.Account__r.Customer_Success_Manager__r.Name,
																   IsActive__c, Is_Super_User__c, Manage_Team__c,
																   Log_Case__c, View_Case_Report__c, View_Certification_Report__c
																   FROM Project_Team_Member__c
																   WHERE Contact__c != NULL AND Customer_Project__c != NULL
																   AND Contact__c = :currentUserContactId AND Customer_Project__c = :userProjectId
																   AND IsActive__c = TRUE AND Customer_Project__r.IsActive__c = TRUE LIMIT 1];

			if(!userProjectPermissions.isEmpty()) {
				String csmName = userProjectPermissions[0].Customer_Project__r.Account__r.Customer_Success_Manager__r.Name == null ? 'support@copa.do' : userProjectPermissions[0].Customer_Project__r.Account__r.Customer_Success_Manager__r.Name;
				Integer noOfcert = getCertsListCount(userProjectId);
				Integer noOfCase = [SELECT Id FROM Case WHERE Customer_Project__c = :userProjectId AND IsClosed = false].size();
				userProjectDetails = new CommunityWrapper.UserProjectDetails(userProjectPermissions[0].Customer_Project__r.Id,
																			 userProjectPermissions[0].Customer_Project__r.Name,
																			 userProjectPermissions[0].Customer_Project__r.Account__r.Name,
																			 Integer.valueOf(userProjectPermissions[0].Customer_Project__r.Number_of_Team_Members__c),
																			 userProjectPermissions[0].IsActive__c, userProjectPermissions[0].Is_Super_User__c,
																			 userProjectPermissions[0].Manage_Team__c,
																			 userProjectPermissions[0].Log_Case__c,
																			 userProjectPermissions[0].View_Case_Report__c, userProjectPermissions[0].View_Certification_Report__c,
																			 csmName, noOfCase, noOfcert);
			}
			return new CommunityWrapper.ResponseWrap(FALSE, NULL, userProjectDetails);
		} catch (Exception ex) {
			return new CommunityWrapper.ResponseWrap(TRUE, ex.getMessage());
		}
	}

	/**
	 * Method to fetch the cases corresponding to a project
	 */
	@AuraEnabled(cacheable=true)
	public static CommunityWrapper.ResponseWrap getCases (String projectId, Integer pageSize, Integer page, Map<String, String> tags, String sortBy, String sortDirection) {
		try {
			Integer offset;
			if(page != null && pageSize != null) {
				offset = (page - 1) * pageSize;
			}
			List<CommunityWrapper.CaseDetails> caseList = new List<CommunityWrapper.CaseDetails>();
			if(checkProjectAccess(projectId, 'Log_Case__c') || checkProjectAccess(projectId, 'View_Case_Report__c')) {
				String soql =
						'SELECT Id' +
						',CaseNumber' +
						',Subject' +
						',Impacted_Area__c' +
						',Status' +
						',CreatedDate' +
						',ClosedDate' +
						',Last_Case_Comment_Time__c' +
						',CreatedBy.Name' +
						' FROM Case' +
						' Where Customer_Project__c != NULL' +
						' AND Customer_Project__c = :projectId';
				String filterWhereClause = getFilterWhereClause(tags);
				if(filterWhereClause != null) {
					soql += ' AND ' + filterWhereClause;
				}
				soql += getSortingClause(CommunityUtils.sanitizeInput(sortBy), CommunityUtils.sanitizeInput(sortDirection));
				if(offset != null) {
				soql += ' LIMIT ' + pageSize + ' OFFSET ' + offset;
				}
				List<Case> caseRecords = Database.query(soql);
				if(!caseRecords.isEmpty()) {
					for(Case cs : caseRecords) {
						caseList.add(new CommunityWrapper.CaseDetails(cs.Id, cs.CaseNumber, '/s/case-details?cid=' + cs.Id, cs.Subject, cs.Impacted_Area__c, cs.Status, cs.CreatedDate, cs.ClosedDate, cs.Last_Case_Comment_Time__c, cs.CreatedBy.Name));
					}
				}
			}
			return new CommunityWrapper.ResponseWrap(FALSE, NULL, caseList);
		} catch (Exception ex) {
			return new CommunityWrapper.ResponseWrap(TRUE, ex.getMessage());
		}
	}

	/**
	 * Method to fetch the Case Deatil
	 */
	@AuraEnabled(cacheable=true)
	public static CommunityWrapper.CaseFieldSetWrap getCaseDetail (String recId) {
		String projId = [SELECT Id, Customer_Project__c FROM Case WHERE Id = :recId LIMIT 1].Customer_Project__c;
		if(!checkProjectAccess(projId, 'View_Case_Report__c')){
			throw new AuraHandledException('You Dont have any access on this Case. Please contact with Syatem Admin.');
		}

		List<Schema.FieldSetMember> flm = SObjectType.Case.FieldSets.Case_Detail_Community.getFields();
		List<Schema.FieldSetMember> fieldSetMemers = new List<Schema.FieldSetMember>();
		for(Integer i = flm.size() - 1; i >= 0; i--){
			fieldSetMemers.add(flm[i]);
		}

		// Handling of reference fields
		Set<String> allFilds = new Set<String>{'CaseNumber'};
		for (Schema.FieldSetMember field : fieldSetMemers) {
			allFilds.add(field.getFieldPath());
			if(field.getFieldPath().contains('ContactId')){
				allFilds.add('Contact.Name');
			}else if(field.getFieldPath().contains('AccountId')){
				allFilds.add('Account.Name');
			}else if(field.getFieldPath().contains('OwnerId')){
				allFilds.add('Owner.Name');
			}else if(field.getFieldPath().contains('CreatedById')){
				allFilds.add('CreatedBy.Name');
			}else if(field.getFieldPath().contains('Customer_Project__c')){
				allFilds.add('Customer_Project__r.Name');
			}
		}

		try {
			String query = 'SELECT Id, '+String.join(new List<String>(allFilds), ', ')+' FROM Case WHERE Id =:recId LIMIT 1';
			Case cs = Database.query(query);
			Map<String, Object> textAreaFieldsMap = new Map<String, Object>();
			Map<String, Object> allOthersFieldsMap = new Map<String, Object>();
			Map<String, String> referenceFieldMap = new Map<String, String>();
			for(Schema.FieldSetMember field : fieldSetMemers){
				if(field.getType() == Schema.DisplayType.TextArea){
					textAreaFieldsMap.put(field.getLabel(), cs.get(field.getFieldPath()));
				}else if(field.getType() == Schema.DisplayType.DateTime){
					allOthersFieldsMap.put(field.getLabel(), Date.valueOf(cs.get(field.getFieldPath())));
				}else if(field.getType() == Schema.DisplayType.Reference){
					String label = field.getLabel().replace('ID', 'Name');
					allOthersFieldsMap.put(label, cs.get(field.getFieldPath()));
					if(field.getFieldPath().contains('ContactId')){
						allOthersFieldsMap.put(label, cs.Contact.Name);
					}else if(field.getFieldPath().contains('AccountId')){
						allOthersFieldsMap.put(label, cs.Account.Name);
					}else if(field.getFieldPath().contains('OwnerId')){
						allOthersFieldsMap.put(label, cs.Owner.Name);
					}else if(field.getFieldPath().contains('CreatedById')){
						allOthersFieldsMap.put(label, cs.CreatedBy.Name);
					}else if(field.getFieldPath().contains('Customer_Project__c')){
						allOthersFieldsMap.put(label, cs.Customer_Project__r.Name);
					}
				}else{
					allOthersFieldsMap.put(field.getLabel(), cs.get(field.getFieldPath()));
				}
			}
			
			return new CommunityWrapper.CaseFieldSetWrap(JSON.serialize(textAreaFieldsMap), JSON.serialize(allOthersFieldsMap));
		} catch (Exception ex) {
			throw new AuraHandledException(ex.getStackTraceString() + '---' +ex.getMessage());
		}
	}

	/**
	 * Method to fetch the cases count corresponding to a project
	 */
	@AuraEnabled(cacheable=true)
	public static CommunityWrapper.ResponseWrap getAllCasesCount (String projectId, Map<String, String> tags) {
		try {
			Integer casesCount = 0;
			if(checkProjectAccess(projectId, 'Log_Case__c') || checkProjectAccess(projectId, 'View_Case_Report__c')) {
				String soql =
					'SELECT Count(Id) CNT' +
					' FROM Case' +
					' Where Customer_Project__c != NULL' +
					' AND Customer_Project__c = :projectId';
				String filterWhereClause = getFilterWhereClause(tags);
				if(filterWhereClause != null) {
					soql += ' AND ' + filterWhereClause;
				}
				List<AggregateResult> casesAggregateResult = Database.query(soql);
				if(!casesAggregateResult.isEmpty()) {
					casesCount = Integer.valueOf(casesAggregateResult[0].get('CNT'));
				}
			}
			return new CommunityWrapper.ResponseWrap(FALSE, NULL, casesCount);
		} catch (Exception ex) {
			return new CommunityWrapper.ResponseWrap(TRUE, ex.getMessage());
		}
	}

	/**
	 * Method to fetch the Project Team members corresponding to a Customer Project
	 */
	@AuraEnabled(cacheable=true)
	public static List<Project_Team_Member__c> getMembersList(String recId) {
		return [SELECT Id, User__c, Profile_Pic_URL__c, Contact_Name__c, Manage_Team__c, Log_Case__c, View_Case_Report__c, View_Certification_Report__c, IsActive__c FROM Project_Team_Member__c WHERE Customer_Project__c = :recId];
	}

	/**
	 * Method to fetch the Project Team members
	 */
	@AuraEnabled(cacheable=false)
	public static Project_Team_Member__c getPTM(String recId) {
		return [SELECT Id, User__c, Profile_Pic_URL__c, Is_Super_User__c, Contact__c, Contact_Name__c, Manage_Team__c, Log_Case__c, View_Case_Report__c, View_Certification_Report__c, IsActive__c FROM Project_Team_Member__c WHERE Id = :recId];
	}

	/**
	 * Method to fetch the Contact corresponding to a Email
	 */
	@AuraEnabled(cacheable=true)
	public static List<Contact> getContactList(String searchKey) {
		return [SELECT Id, Name FROM Contact WHERE Email = :searchKey];
	}

	/**
	 * Method to create or update Project Team member corresponding to a Project
	 */
	@AuraEnabled
	public static Project_Team_Member__c createUpdatePTM(Boolean isUpdate, Map<String, Object> recData) {
		Project_Team_Member__c ptm = new Project_Team_Member__c();
		ptm.Contact__c = String.valueOf(recData.get('Contact__c'));
		ptm.IsActive__c = Boolean.valueOf(recData.get('IsActive__c'));
		ptm.Is_Super_User__c = Boolean.valueOf(recData.get('Is_Super_User__c'));
		ptm.Log_Case__c = Boolean.valueOf(recData.get('Log_Case__c'));
		ptm.View_Case_Report__c = Boolean.valueOf(recData.get('View_Case_Report__c'));
		ptm.View_Certification_Report__c = Boolean.valueOf(recData.get('View_Certification_Report__c'));
		ptm.Manage_Team__c = Boolean.valueOf(recData.get('Manage_Team__c'));

		if(isUpdate){
			ptm.Id = String.valueOf(recData.get('Id'));
		}else{
			ptm.Customer_Project__c = String.valueOf(recData.get('Customer_Project__c'));
		}
		upsert ptm;

		return ptm;
	}

	/**
	 * Method to invite the Project Team member to Sign-Up on community, this method will send an email invite.
	 */
	@AuraEnabled
	public static void invitePTM(String emailId) {
		EmailTemplate emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body FROM EmailTemplate WHERE Name = 'Invite User To Join Community'];
		Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
		message.targetobjectid = UserInfo.getUserId();
		message.setTemplateID(emailTemplate.Id);
		message.setSaveAsActivity(false);
		message.toAddresses = new String[] { emailId };
		Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
		Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
	}

	/**
	 * Method to fetch the all certifications Name.
	 */
	@AuraEnabled(cacheable=true)
	public static List<String> getCertNames(){
		List<Academy_Certification_Program__c> acpList = [SELECT Id, Name FROM Academy_Certification_Program__c WHERE Status__c = 'Valid' ORDER BY Name];
		List<String> certNames = new List<String>();
		for(Academy_Certification_Program__c acp : acpList){
			certNames.add(acp.Name);
		}
		return certNames;
	}

	/**
	 * Method to fetch the certifications corresponding to a Account on Project, also uses filters to filter data.
	 */
	@AuraEnabled(cacheable=true)
	public static List<Academy_Certification__c> getCertsList(String recId, String searchAll, String userName, String certName, String certStatus, String dateType, String startDate, String endDate) {
		List<Academy_Certification__c> dataList = new List<Academy_Certification__c>();
		if(checkProjectAccess(recId, 'View_Certification_Report__c')) {
			String accId = [SELECT Id, Account__c FROM Project__c WHERE Id =: recId LIMIT 1 ].Account__c;
			List<Contact> conList = [SELECT Id FROM Contact WHERE AccountId =: accId OR Account__c =: accId];

			List<Academy_Certification__c> certData = [SELECT Id,Program_Name__c,Certification_Id__c,Certification_Examination__r.Date__c,Expiration_Date__c,Earned_Date__c,Certification_Program__r.Name, Certification_Student__c,Certification_Student__r.Contact__r.EMAIL, Status__c, Student_Name__c FROM Academy_Certification__c WHERE Certification_Student__r.Contact__c IN :conList];
			Map<String,Academy_Certification__c> contactCertificationProgramKeyWithValidCertificateMap = new Map<String,Academy_Certification__c>();
			Map<String,Academy_Certification__c> contactCertificationProgramKeyWithExpiredCertificateMap = new Map<String,Academy_Certification__c>();
			for(Academy_Certification__c AC : certData){
				String mapKey = String.valueOf(AC.Certification_Student__r.Contact__c) + String.valueof(AC.Certification_Program__c);
				if(AC.Status__c == 'Valid') {
					contactCertificationProgramKeyWithValidCertificateMap.put(mapKey, AC);
				}
				else if(AC.Status__c == 'Expired' && !contactCertificationProgramKeyWithValidCertificateMap.containsKey(mapKey)) {
					contactCertificationProgramKeyWithExpiredCertificateMap.put(mapKey, AC);
				}
				if(contactCertificationProgramKeyWithValidCertificateMap.containsKey(mapKey) && contactCertificationProgramKeyWithExpiredCertificateMap.containsKey(mapKey)) {
					contactCertificationProgramKeyWithExpiredCertificateMap.remove(mapKey);
				}
			}
			certData = contactCertificationProgramKeyWithValidCertificateMap.values();
			certData.addAll(contactCertificationProgramKeyWithExpiredCertificateMap.values());

			String query = 'SELECT Id,Program_Name__c,Certification_Id__c,Certification_Examination__r.Date__c,Expiration_Date__c,Earned_Date__c,Certification_Program__r.Name, Certification_Student__c,Certification_Student__r.Contact__r.EMAIL, Status__c, Student_Name__c FROM Academy_Certification__c WHERE Certification_Student__r.Contact__c IN :conList AND Id IN :certData';
			if(String.isNotBlank(searchAll)){
				String st1 = '%' + searchAll + '%';
				query += ' AND (Program_Name__c LIKE \'' + st1 + '\' OR Student_Name__c LIKE \'' + st1 + '\' OR Status__c LIKE \'' + st1 + '\')';
			}
			if(String.isNotBlank(userName)){
				String st2 = '%' + userName + '%';
				query += ' AND (Student_Name__c LIKE \'' + st2 + '\')';
			}
			if(String.isNotBlank(certName)){
				String st3 = '%' + certName + '%';
				query += ' AND (Program_Name__c LIKE \'' + st3 + '\')';
			}
			if(String.isNotBlank(certStatus)){
				String st4 = '%' + certStatus + '%';
				query += ' AND (Status__c LIKE \'' + st4 + '\')';
			}
			if(String.isNotBlank(dateType)){
				if(dateType == 'Expiring Date'){
					if(String.isNotBlank(startDate)){
						query += ' AND Expiration_Date__c >= ' + startDate;
					}
					if(String.isNotBlank(endDate)){
						query += ' AND Expiration_Date__c <= ' + endDate;
					}
				}else{
					if(String.isNotBlank(startDate)){
						String startDateValue = startDate + 'T00:00:00Z';
						query += ' AND Earned_Date__c >= ' + startDateValue;
					}
					if(String.isNotBlank(endDate)){
						String endDateValue = endDate + 'T00:00:00Z';
						query += ' AND Earned_Date__c <= ' + endDateValue;
					}
				}
			}
			dataList = Database.query(query);
		}
		return dataList;
	}

	/**
	 * Method to fetch the certifications corresponding to a Account on Project, also uses filters to filter data.
	 */
	private static Integer getCertsListCount(String recId) {
		List<Academy_Certification__c> dataList = new List<Academy_Certification__c>();
		String accId = [SELECT Id, Account__c FROM Project__c WHERE Id =: recId LIMIT 1 ].Account__c;
		List<Contact> conList = [SELECT Id FROM Contact WHERE AccountId =: accId OR Account__c =: accId];

		List<Academy_Certification__c> certData = [SELECT Id,Program_Name__c,Certification_Id__c,Certification_Examination__r.Date__c,Expiration_Date__c,Earned_Date__c,Certification_Program__r.Name, Certification_Student__c,Certification_Student__r.Contact__r.EMAIL, Status__c, Student_Name__c FROM Academy_Certification__c WHERE Certification_Student__r.Contact__c IN :conList];
		Map<String,Academy_Certification__c> contactCertificationProgramKeyWithValidCertificateMap = new Map<String,Academy_Certification__c>();
		Map<String,Academy_Certification__c> contactCertificationProgramKeyWithExpiredCertificateMap = new Map<String,Academy_Certification__c>();
		for(Academy_Certification__c AC : certData){
			String mapKey = String.valueOf(AC.Certification_Student__r.Contact__c) + String.valueof(AC.Certification_Program__c);
			if(AC.Status__c == 'Valid') {
				contactCertificationProgramKeyWithValidCertificateMap.put(mapKey, AC);
			}
			else if(AC.Status__c == 'Expired' && !contactCertificationProgramKeyWithValidCertificateMap.containsKey(mapKey)) {
				contactCertificationProgramKeyWithExpiredCertificateMap.put(mapKey, AC);
			}
			if(contactCertificationProgramKeyWithValidCertificateMap.containsKey(mapKey) && contactCertificationProgramKeyWithExpiredCertificateMap.containsKey(mapKey)) {
				contactCertificationProgramKeyWithExpiredCertificateMap.remove(mapKey);
			}
		}
		certData = contactCertificationProgramKeyWithValidCertificateMap.values();
		certData.addAll(contactCertificationProgramKeyWithExpiredCertificateMap.values());

		String query = 'SELECT Id,Program_Name__c,Certification_Id__c,Certification_Examination__r.Date__c,Expiration_Date__c,Earned_Date__c,Certification_Program__r.Name, Certification_Student__c,Certification_Student__r.Contact__r.EMAIL, Status__c, Student_Name__c FROM Academy_Certification__c WHERE Certification_Student__r.Contact__c IN :conList AND Id IN :certData';
		dataList = Database.query(query);
		return dataList.size();
	}

	/**
	 * Method to return the where clause for a dynamic query corresponding to a filters
	 */
	private static String getFilterWhereClause(Map<String, String> tags) {
		List<String> whereClauses = new List<String>();
		for(String tagsKey: tags.keySet()) {
			if(tagsKey.equalsIgnoreCase('searchText') && String.isNotBlank(tags.get(tagsKey))) {
				String newSearchText = '%' + CommunityUtils.sanitizeInput(tags.get(tagsKey)) + '%';
				whereClauses.add('(CaseNumber LIKE \'' + newSearchText + '\' OR Subject LIKE \'' + newSearchText + '\')');
			}
			else if(tagsKey.equalsIgnoreCase('createdBy') && String.isNotBlank(tags.get(tagsKey))) {
				String caseCreatedBy = '%' + CommunityUtils.sanitizeInput(tags.get(tagsKey)) + '%';
				whereClauses.add('(CreatedBy.Name LIKE \'' + caseCreatedBy + '\')');
			}
			else if((tagsKey.equalsIgnoreCase('startDate') || tagsKey.equalsIgnoreCase('endDate')) && String.isNotBlank(tags.get(tagsKey))) {
				String fieldName = (tags.containsKey('filterDateType') && String.isNotBlank(tags.get('filterDateType')) ) ? tags.get('filterDateType') : null;
				if(fieldName != null) {
					String dateWhereClause = getDateFilterWhereClause(fieldName, CommunityUtils.sanitizeInput(tags.get(tagsKey)), tagsKey);
					if(dateWhereClause != null) {
						whereClauses.add(dateWhereClause);
					}
				}
			}
			else if(tagsKey.equalsIgnoreCase('status') && String.isNotBlank(tags.get(tagsKey))) {
				if(tags.get(tagsKey).equalsIgnoreCase('Closed')) {
					whereClauses.add('IsClosed = true');
				}
				else if(tags.get(tagsKey).equalsIgnoreCase('Opened')) {
					whereClauses.add('IsClosed = false');
				}
				else {
					whereClauses.add(tagsKey + '=\'' + CommunityUtils.sanitizeInput(tags.get(tagsKey))  + '\'');
				}
			}
			else if(!tagsKey.equalsIgnoreCase('filterDateType') && String.isNotBlank(tags.get(tagsKey))) {
				whereClauses.add(tagsKey + '=\'' + CommunityUtils.sanitizeInput(tags.get(tagsKey))  + '\'');
			}
		}
		if(!whereClauses.isEmpty()) {
			return String.join(whereClauses, ' AND ');
		}
		return null;
	}

	/**
	 * Method to return the where clause for date for a dynamic query.
	 */
	private static String getDateFilterWhereClause(String fieldName, String value, String dateType) {
		String dateValue = value + 'T00:00:00Z';
		if(dateType.equalsIgnoreCase('startDate')) {
			return fieldName + ' >= ' + dateValue ;
		}
		else if(dateType.equalsIgnoreCase('endDate')) {
			return fieldName + ' <= ' + dateValue ;
		}
		return null;
	}

	/**
	 * Method to return the sorting clause for a dynamic query.
	 */
	private static String getSortingClause(String sortBy, String sortDirection) {
		String sortingClause = '';
		if(String.isNotBlank(sortBy)){
			if(sortBy.equalsIgnoreCase('ImpactedArea')) {
				sortBy = 'Impacted_Area__c';
			}
			else if(sortBy.equalsIgnoreCase('CaseURL')) {
				sortBy = 'CaseNumber';
			}
			else if(sortBy.equalsIgnoreCase('CreatedBy')) {
				sortBy = 'CreatedBy.Name';
			}
			else if(sortBy.equalsIgnoreCase('LastCaseCommentTime')) {
				sortBy = 'Last_Case_Comment_Time__c';
			}
			sortingClause += ' ORDER BY ' + sortBy;
			if(String.isNotBlank(sortDirection)) {
				sortingClause += ' ' + sortDirection + ' NULLS LAST';
			}
		}
		return sortingClause;
	}

	/**
	 * Method to return all the active Projects corresponding to a Active Project Team Member record with Log Case field true.
	 */
	public static List<CommunityWrapper.PicklistEntry> getUserProjectsWithLogCaseAccess(){
		Id currentUserContactId = ( CommunityUtils.getLoginUser() != null ) ? CommunityUtils.getLoginUser().ContactId : null;
		List<CommunityWrapper.PicklistEntry> userProjectOptions = new List<CommunityWrapper.PicklistEntry>();
		Set<Id> userProjectsId = new Set<Id>();
		List<Project_Team_Member__c> userProjectTeamMembers = [SELECT Customer_Project__c, Customer_Project__r.Name FROM Project_Team_Member__c
															   WHERE Contact__c != NULL AND Contact__c = :currentUserContactId
															   AND Customer_Project__c != NULL AND Log_Case__c = TRUE
															   AND IsActive__c = TRUE AND Customer_Project__r.IsActive__c = TRUE ORDER BY Customer_Project__r.Name];
		for(Project_Team_Member__c projectTeamMember : userProjectTeamMembers) {
			if(!userProjectsId.Contains(projectTeamMember.Customer_Project__c)) {
				userProjectOptions.add(new CommunityWrapper.PicklistEntry(projectTeamMember.Customer_Project__r.Name, projectTeamMember.Customer_Project__c));
				userProjectsId.add(projectTeamMember.Customer_Project__c);
			}
		}
		return userProjectOptions;
	}

	/**
	 * Method to check the project team member have particular (based on fieldName) access on corresponding to a project
	 */
	public static Boolean checkProjectAccess(String projectId, String fieldName){
		Id currentUserContactId = ( CommunityUtils.getLoginUser() != null ) ? CommunityUtils.getLoginUser().ContactId : null;
		List<Project_Team_Member__c> userProjectTeamMembers = new List<Project_Team_Member__c>();
		if(String.isNotBlank(fieldName)) {
			String soql =
						'SELECT ' + fieldName + ' FROM Project_Team_Member__c' +
						' WHERE Contact__c != NULL AND Contact__c = :currentUserContactId' +
						' AND Customer_Project__c != NULL AND ' + fieldName + ' = TRUE' +
						' AND IsActive__c = TRUE AND Customer_Project__r.IsActive__c = TRUE AND Customer_Project__c = :projectId';

			userProjectTeamMembers = Database.query(soql);
		}
		if(!userProjectTeamMembers.isEmpty()) {
			return (Boolean) userProjectTeamMembers[0].get(fieldName);
		}
		return false;
	}
}