/**
 * Utility class for community
 */
public class CommunityUtils {
	/**
	 * Method to get the current logged in user with ComtactId
	*/
	public static User getLoginUser(){
		Id currentUserId = UserInfo.getUserId();
		List<User> currentUser = [SELECT Id, ContactId FROM User WHERE Id = :currentUserId];
		if(!currentUser.isEmpty()) {
			return currentUser[0];
		}
		return null;
	}

	/**
	 * Method to sanitize the inputs
	*/
	public static String sanitizeInput(String input) {
		return String.escapeSingleQuotes(input);
	}
}