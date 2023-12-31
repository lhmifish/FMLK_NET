package com.fmlk.util;

import java.io.FileInputStream;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.Charset;
import java.util.Properties;
import org.apache.commons.codec.binary.Base64;
import org.apache.commons.codec.digest.DigestUtils;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.ContentType;
import org.apache.http.entity.mime.HttpMultipartMode;
import org.apache.http.entity.mime.MultipartEntityBuilder;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;
import org.springframework.web.multipart.MultipartFile;
import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;

public class FileServerUtils {

	private static String folderNameSales = "/销售";
	private static String folderNameBeforeSales = "/售前";
	private static String folderNameAfterSales = "/售后";
	private static String folderNamePurchase = "/采购";
	private static String folderNameADM = "/行政";
	private static String folderNameOther = "/其他";
	private static String folderProjectReport = "/LanstarNet/FileData/Group/public/home/项目文档/";
	private static String folderProjectCase = "/LanstarNet/FileData/Group/public/home/Case文档/";
	private static String folderTender = "/LanstarNet/FileData/Group/public/home/投标文档/";
	private static String folderContract = "/LanstarNet/FileData/Group/public/home/合同文档/";

	public static JSONObject get(String url) {
		JSONObject jb = null;
		HttpGet request = new HttpGet(url);
		CloseableHttpClient httpclient = HttpClients.createDefault();
		try {
			HttpResponse response = httpclient.execute(request);
			String reposeContent = EntityUtils.toString(response.getEntity(), Charset.forName("UTF-8"));
	        jb = JSON.parseObject(reposeContent);
        } catch (Exception e) {
			jb = null;
		}
		return jb;
	}

	public static JSONObject post(String url) {
		JSONObject jb = null;
		HttpPost request = new HttpPost(url);
		CloseableHttpClient httpclient = HttpClients.createDefault();
		try {
			HttpResponse response = httpclient.execute(request);
			String reposeContent = EntityUtils.toString(response.getEntity(), Charset.forName("UTF-8"));
		    jb = JSON.parseObject(reposeContent);
		} catch (Exception e) {
			jb = null;
		}
		return jb;
	}

	public static JSONObject post(String url, MultipartFile uploadFile, String fileName, String boundary)
			throws IOException {
		JSONObject jb = null;
		try {
			CloseableHttpClient httpclient = HttpClients.createDefault();
			HttpPost request = new HttpPost(url);
			ContentType ctype = ContentType.MULTIPART_FORM_DATA;
			MultipartEntityBuilder builder = MultipartEntityBuilder.create();
			builder.setCharset(Charset.forName("utf-8"));
			builder.setMode(HttpMultipartMode.BROWSER_COMPATIBLE);
			builder.addBinaryBody("file", uploadFile.getInputStream(), ctype, fileName);
			builder.setBoundary(boundary);
			HttpEntity entity = builder.build();
			request.setEntity(entity);
			HttpResponse response = httpclient.execute(request);
			String reposeContent = EntityUtils.toString(response.getEntity(), Charset.forName("UTF-8"));
			jb = JSON.parseObject(reposeContent);
		} catch (Exception e) {
			jb = null;
		}
		return jb;
	}

	public static String getAccessToken() {
		try {
			Properties prop = new Properties();
			String path = DBConnection.class.getResource("/").getPath();
			path = path.substring(1, path.indexOf("WEB-INF/classes")) + "property/upload.properties";
			path = path.replaceAll("%20", " ");
			prop.load(new FileInputStream(path));
			String server = prop.getProperty("upload.fileServer");
			String apiLoginTonken = prop.getProperty("upload.apiLoginTonken");
			String account = prop.getProperty("upload.account");
			String login_token = URLEncoder.encode(getLoginToken(account, apiLoginTonken), "UTF-8");
			String url = String.format("http://" + server + "/?user/loginSubmit&isAjax=1&getToken=1&login_token=%s",
					login_token);
			JSONObject jb = get(url);
			if (jb.getBoolean("code")) {
				return jb.getString("data");
			} else {
				return "";
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return "";
	}

	private static String getLoginToken(String name, String apiLoginTonken) {
		try {
			String md5 = DigestUtils.md5Hex(name + apiLoginTonken);
			String base64 = new String(Base64.encodeBase64(name.getBytes("UTF-8")));
			return base64 + "|" + md5;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

	/*
	 * public static String getFileList(String accessToken, String createYear) { try
	 * { Properties prop = new Properties(); String path =
	 * DBConnection.class.getResource("/").getPath(); path = path.substring(1,
	 * path.indexOf("WEB-INF/classes")) + "property/upload.properties"; path =
	 * path.replaceAll("%20", " "); prop.load(new FileInputStream(path)); String
	 * server = prop.getProperty("upload.fileServer"); String url = String.format(
	 * "http://" + server +
	 * "/?explorer/pathList&accessToken=%s&path=%s",accessToken,
	 * URLEncoder.encode("/LanstarNet/FileData/Group/public/home/项目文档/" + createYear
	 * + "年/", "UTF-8"));
	 * 
	 * JSONObject jb = get(url); if (jb.getBoolean("code")) { return
	 * jb.getString("data"); } else { return ""; } } catch (Exception e) {
	 * e.printStackTrace(); } return ""; }
	 */

	public static String createFolder(String accessToken, String createYear, String projectId, int reportType) {
		try {
			Properties prop = new Properties();
			String path = DBConnection.class.getResource("/").getPath();
			path = path.substring(1, path.indexOf("WEB-INF/classes")) + "property/upload.properties";
			path = path.replaceAll("%20", " ");
			prop.load(new FileInputStream(path));
			String server = prop.getProperty("upload.fileServer");
			String folderName = "";
			if (reportType == 1) {
				//销售进展报告
				folderName = folderNameSales;
			} else if (reportType == 2) {
				//技术售前进展报告
				folderName = folderNameBeforeSales;
			} else if (reportType == 3) {
				//技术售后进展报告
				folderName = folderNameAfterSales;
			} else if (reportType == 4) {
				//采购进展报告
				folderName = folderNamePurchase;
			} else if (reportType == 5){
				//行政进展报告
				folderName = folderNameADM;
			} else {
				//其他
				folderName = folderNameOther;
			}
			
			String folderPath = null;
			if(reportType == 99) {
				folderPath = folderProjectCase  + projectId;
			}else if(reportType == 98) {
				folderPath = folderTender  + projectId;
			}else if(reportType == 97) {
				folderPath = folderContract  + projectId;
			}else {
				folderPath = folderProjectReport + createYear + "年/" + projectId
						+ folderName;
			}
			String url = String.format("http://" + server + "/?explorer/mkdir&accessToken=%s&path=%s", accessToken,
					URLEncoder.encode(folderPath, "UTF-8"));
			JSONObject jb = get(url);
			if (jb.getBoolean("code") && jb.getString("data").equals("Create successful! ")) {
				return jb.getString("info");
			} else {
				return "";
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return "";
	}

	public static String createFile(String accessToken, String createYear, String projectId, int reportType,
			MultipartFile uploadFile, int chunk, long fileSize, String fileName, int chunks, String boundary) {
		try {
			Properties prop = new Properties();
			String path = DBConnection.class.getResource("/").getPath();
			path = path.substring(1, path.indexOf("WEB-INF/classes")) + "property/upload.properties";
			path = path.replaceAll("%20", " ");
			prop.load(new FileInputStream(path));
			String server = prop.getProperty("upload.fileServer");
			String folderName = "";
			if (reportType == 1) {
				folderName = folderNameSales;
			} else if (reportType == 2) {
				folderName = folderNameBeforeSales;
			} else if (reportType == 3) {
				folderName = folderNameAfterSales;
			} else if (reportType == 4) {
				folderName = folderNamePurchase;
			} else if (reportType == 5){
				folderName = folderNameADM;
			} else {
				folderName = folderNameOther;
			}
			String filePath = null;
			if(reportType == 99) {
				filePath = folderProjectCase  + projectId + "/";
			}else if(reportType == 98) {
				filePath = folderTender  + projectId + "/";
			}else if(reportType == 97) {
				filePath = folderContract  + projectId + "/";
			}else {
				filePath = folderProjectReport + createYear + "年/" + projectId
						+ folderName + "/";
			}
			String url = String.format(
					"http://" + server + "/?explorer/fileUpload&accessToken=%s&upload_to=%s&chunks=%s&chunk=%s&size=%s",
					accessToken, URLEncoder.encode(filePath, "UTF-8"), chunks, chunk, fileSize);
			JSONObject jb = post(url, uploadFile, fileName, boundary);
			System.out.println(jb.toString());
			
			if (jb.getBoolean("code") && jb.getString("data").equals("upload_success")) {
				if (jb.getString("info") == null) {
					return "no_info";
				} else {
					return jb.getString("info");
				}
			} else {
				return "";
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return "";
	}

	public static String getFileList(String accessToken, String createYear, String projectId, int reportType) {
		try {
			Properties prop = new Properties();
			String path = DBConnection.class.getResource("/").getPath();
			path = path.substring(1, path.indexOf("WEB-INF/classes")) + "property/upload.properties";
			path = path.replaceAll("%20", " ");
			prop.load(new FileInputStream(path));
			String server = prop.getProperty("upload.fileServer");
			String folderName = "";
			if (reportType == 1) {
				folderName = folderNameSales;
			} else if (reportType == 2) {
				folderName = folderNameBeforeSales;
			} else if (reportType == 3) {
				folderName = folderNameAfterSales;
			} else if (reportType == 4) {
				folderName = folderNamePurchase;
			} else if (reportType == 5){
				folderName = folderNameADM;
			} else {
				folderName = folderNameOther;
			}
			String filePath = null;
			if(reportType == 99) {
				filePath = folderProjectCase + projectId + "/";
			}else if(reportType == 98) {
				filePath = folderTender + projectId + "/";
			}else if(reportType == 97) {
				filePath = folderContract + projectId + "/";
			}else {
				filePath = folderProjectReport + createYear + "年/" + projectId
						+ folderName + "/";
			}
			String url = String.format("http://" + server + "/?explorer/pathList&accessToken=%s&path=%s", accessToken,
					URLEncoder.encode(filePath, "UTF-8"));
			JSONObject jb = post(url);
			if (jb.getBoolean("code")) {
				JSONObject jb2 = jb.getJSONObject("data");
				JSONArray fileListArray = jb2.getJSONArray("fileList");
				return fileListArray.toString();
			} else {
				return "";
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return "";
	}

	public static String downloadFile(String accessToken, String createYear, String projectId, int reportType,
			String fileName) {
		try {
			Properties prop = new Properties();
			String path = DBConnection.class.getResource("/").getPath();
			path = path.substring(1, path.indexOf("WEB-INF/classes")) + "property/upload.properties";
			path = path.replaceAll("%20", " ");
			prop.load(new FileInputStream(path));
			String server = prop.getProperty("upload.fileServer");
			String folderName = "";
			if (reportType == 1) {
				folderName = folderNameSales;
			} else if (reportType == 2) {
				folderName = folderNameBeforeSales;
			} else if (reportType == 3) {
				folderName = folderNameAfterSales;
			} else if (reportType == 4) {
				folderName = folderNamePurchase;
			} else {
				folderName = folderNameOther;
			}
			String filePath = null;
			if(reportType == 99) {
				filePath = folderProjectCase + projectId + "/" + fileName;
			}else if(reportType == 98) {
				filePath = folderTender + projectId + "/" + fileName;
			}else if(reportType == 97) {
				filePath = folderContract + projectId + "/" + fileName;
			}else {
				filePath = folderProjectReport + createYear + "年/" + projectId
						+ folderName + "/" + fileName;
			}
			String url = String.format("http://" + server + "/?explorer/fileDownload&accessToken=%s&path=%s", accessToken,
					URLEncoder.encode(filePath, "UTF-8"));
			return url;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return "";
	}
}
