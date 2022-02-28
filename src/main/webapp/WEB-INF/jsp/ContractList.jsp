<%@ page language="java" contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"%>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="pragma" content="no-cache" />
<meta http-equiv="cache-control" content="no-cache" />
<title>合同信息管理</title>
<link rel="stylesheet" type="text/css"
	href="${pageContext.request.contextPath}/css/css.css?v=1997" />
<link rel="stylesheet"
	href="${pageContext.request.contextPath}/css/select4.css?v=1997" />
<link rel="stylesheet" type="text/css"
	href="${pageContext.request.contextPath}/css/calendar.css" />

<script type="text/javascript"
	src="${pageContext.request.contextPath}/js/jquery-3.2.1.min.js"></script>
<script src="${pageContext.request.contextPath}/js/select3.js"></script>
<script type="text/javascript"
	src="${pageContext.request.contextPath}/js/validation.js"></script>
<script type="text/javascript"
	src="${pageContext.request.contextPath}/js/calendar.js"></script>
<script src="${pageContext.request.contextPath}/js/checkPermission.js"></script>
<script src="${pageContext.request.contextPath}/js/changePsd.js"></script>
<script src="${pageContext.request.contextPath}/js/commonUtils.js?v=2022"></script>
<script src="${pageContext.request.contextPath}/js/getObjectList.js"></script>
<style type="text/css">
a:hover {
	color: #FF00FF
} /* 鼠标移动到链接上 */

::-webkit-scrollbar{
display:none;
}

html {
	-ms-overflow-style: none;
	/*火狐下隐藏滚动条*/
	overflow: -moz-scrollbars-none;
}
</style>

<script type="text/javascript">
	var page;
	var lastPage;
	var deleteId;
	var sId;
	var host;
	var isPermissionEdit;
	var isPermissionEditArr;
	var tUploadFileInfo;
	var chunks;
	var sliceSize;
	var currentChunk;
	
	$(document).ready(function() {
		sId = "${sessionId}";
		host = "${pageContext.request.contextPath}";
		checkEditPremission(43, 0);
		sliceSize = 1 * 1024 * 1024;
	});
	
	
	function initialPage() {
		page = 1;
		getCompanyList("", 0, 0, 1);
		getSalesList(0);
		initDate();
		getContractList(page);
		$("#projectId").select2({});
		$("#companyId").select2({});
		$("#salesId").select2({});
	}

	function initDate() {
		$('#dd').calendar({
			trigger : '#date1',
			zIndex : 999,
			format : 'yyyy/mm/dd',
			onSelected : function(view, date, data) {
			},
			onClose : function(view, date, data) {
				$('#date1').val(formatDate(date).substring(0, 10));
			}
		});

		$('#dd2').calendar({
			trigger : '#date2',
			zIndex : 999,
			format : 'yyyy/mm/dd',
			onSelected : function(view, date, data) {
			},
			onClose : function(view, date, data) {
				$('#date2').val(formatDate(date).substring(0, 10));
			}
		});
	}
	
	function getContractList(mPage) {
		page = mPage;
		var companyId = $("#companyId").val();
		companyId = (companyId == 0 || companyId == null) ? "" : companyId;
		var projectId = $("#projectId").val();
		projectId = (projectId == 0 || projectId == null) ? "" : projectId;
		var salesId = $("#salesId").val();
		salesId = (salesId == null) ? 0 : salesId;
		var contractNum = $("#contractNum").val().trim();
		var date1 = $("#date1").val();
		var date2 = $("#date2").val();

		if (new Date(date1) > new Date(date2) && date1 != "" && date2 != "") {
			alert("错误：第一个日期不能晚于第二个日期");
			return;
		}
		date1 = (date1=="")?"none":date1;
		date2 = (date2=="")?"none":date2;
		
		$
				.ajax({
					url : "${pageContext.request.contextPath}/getContractList",
					type : 'GET',
					data : {
						"contractNum" : contractNum,
						"projectId" : projectId,
						"dateForContract" : date1 + "-" + date2,
						"saleUser" : salesId,
						"companyId" : companyId
					},
					cache : false,
					async : false,
					success : function(returndata) {
						var contractArr = new Array();
						var data = eval("(" + returndata + ")").contractlist;
						var str = "";
						var num = data.length;
						if (num > 0) {
							lastPage = Math.ceil(num / 10);
							for ( var i in data) {
								if (i >= 10 * (mPage - 1)
										&& i <= 10 * mPage - 1) {
									contractArr.push(data[i].saleUser);
									var contractUploadInfo = "";
									if (data[i].isUploadContract) {
										contractUploadInfo = "下载";
									} else {
										contractUploadInfo = "点击请上传";
									}
									
									str += '<tr style="width:1300px"><td style="width:14%" class="tdColor2">'
											+ data[i].contractNum
											+ '</td>'
											+ '<td style="width:28%" class="tdColor2">'
											+ getProject(data[i].projectId)
											+ '</br>'
											+ getCompany(data[i].companyId)
											+ '</td>'
											+ '<td style="width:10%" class="tdColor2">'
											+ getUser(data[i].saleUser)
											+ '</td>'
											+ '<td style="width:10%" class="tdColor2">'
											+ '<a href="#" id="a_'
											+ i
											+ '" onclick="getUploadInfo('
											+ i
											+ ','
											+ data[i].id
											+ ',\''
											+ data[i].projectId
											+ '\',\''
											+ data[i].contractNum
											+ '\','
											+ data[i].saleUser
											+ ',\''
											+ data[i].companyId
											+ '\')">'		
											+ contractUploadInfo
											+ '</a></td>'
											+ '<td style="width:20%" class="tdColor2">'
											+ data[i].dateForContract
											+ '</td>'
											+ '<td style="width:10%" class="tdColor2">'
											+ '<a href="#" onclick="getPurchaseInfo(\''+ data[i].contractNum +'\')" >查看</a>'
											+ '</td>'
											+ '<td style="width:8%" class="tdColor2">'
										    + '<img title="查看" name="img_edit" class="operation" src="../image/update.png" style="vertical-align:middle" onclick="toEditContractPage('
 											+ data[i].id
 											+ ')"/>'
 											+ '<a name="a_edit" style="vertical-align:middle" onclick="toEditContractPage('
 											+ data[i].id
 											+ ')">查看</a>'

											+'</td></tr>';
								}
							}
						} else {
							lastPage = 1;
							str += '<tr style="height:40px;text-align: center;"><td style="color:red;width:1300px;" border=0>没有你要找的合同</td></tr>';
						}
						document.getElementById('p').innerHTML = mPage + "/"
								+ lastPage;
						$("#tb").empty();
						$("#tb").append(str);
						matchUserPremission(contractArr);
					},
					error : function(XMLHttpRequest, textStatus, errorThrown) {
					}
				});
	}
	
	function getUploadInfo(t, mId, mProjectId, mContractNum, mSales,mCompanyId) {
		var state = document.getElementById("a_" + t).innerHTML;
		if (state == "下载") {
			downloadContarct(getProjectReport(mProjectId), mProjectId);
		} else {
			uploadContractWin(t, mId, mContractNum, mSales, mProjectId,mCompanyId);
		}
	}
	
	function uploadContractWin(t, tId, tContractNum, tSalesId, tProjectId,tCompanyId) {
		if (!isPermissionEditArr[t % 10]) {
			alert("你没有权限上传此合同文件");
		} else {
			$("#progressDiv").hide();
			$("#myfile").val("");
			document.getElementById("progress").style.width = 0;
			document.getElementById("progress").innerHTML = "";
			$("#banDel2").show();
			tUploadFileInfo = tContractNum + "#" + tSalesId + "#" + tProjectId
					+ "#" + tId + "#" + tCompanyId;
		}
	}
	
	function addContractReport(){
		var myFile = document.getElementById("myfile").files[0];
		//alert(myFile.size);
		if (myFile != undefined) {
			if (myFile.size > 1 * 1024 * 1024 * 1024) {
				alert("单个文件上传不能大于1GB");
			} else {
				chunks = Math.ceil(myFile.size / sliceSize);
				//alert(chunks);
				$("#progressDiv").show();
				currentChunk = 0;
				doUploadFile(myFile);
			}
		} else {
			alert("请选择合同文件");
		}
	}
	
	function doUploadFile(tFile) {
		if (currentChunk < chunks) {
			var formData = new FormData();
			formData.append('reportType', 97);
			formData.append('projectId', tUploadFileInfo.split("#")[2]);
			formData.append('createYear', "");
			formData.append('fileSize', tFile.size);
			formData.append('fileName', tFile.name);
			formData.append('chunks', chunks);
			formData.append('chunk', currentChunk);
			formData.append('file', getSliceFile(tFile, currentChunk));
			
			formData.append('salesId', tUploadFileInfo.split("#")[1]);
			formData.append('userId', getUserInfo(sId));
            
			formData.append('projectName', getProject(tUploadFileInfo.split("#")[2]).projectName);
			formData.append('companyName', getCompany(tUploadFileInfo.split("#")[4]).companyName);
			
			
			var xhr = new XMLHttpRequest();
			xhr.open("POST", host + "/addProjectReport");
			xhr.send(formData);
			xhr.onreadystatechange = function() {
				if (xhr.readyState == 4) {
					var errcode = eval("(" + xhr.responseText + ")").errcode;
					var info = eval("(" + xhr.responseText + ")").info;
					if (errcode == 0) {
						upDateProgress(currentChunk);
						currentChunk++;
						doUploadFile(tFile);
					} else {
						alert("上传错误，错误信息：" + info);
						return;
					}
				}
			}
		} else {
			//alert("开始编辑合同信息")
			editContract(tFile);
		}
	}
	
	function editContract(mFile) {
		var arrayPaymentInfo = new Array();    
		arrayPaymentInfo.push("1");
		//alert(arrayPaymentInfo.length)
		$.ajax({
			url : host + "/editContract",
			type : 'POST',
			cache : false,
			dataType : "json",
			data : {
				"contractNum" : tUploadFileInfo.split("#")[0],
				"companyId" : tUploadFileInfo.split("#")[4],
				"projectId" : tUploadFileInfo.split("#")[2],
				"saleUser" : tUploadFileInfo.split("#")[1],
				"dateForContract" :"none-none",
				"contractAmount" : 0,
				"taxRate" : 0,
				"serviceDetails" : "",
				"paymentInfo" : arrayPaymentInfo,
				"id":tUploadFileInfo.split("#")[3],
				"isUploadContract":true
			},
			traditional : true,
			success : function(returndata) {
				var data = returndata['errcode'];
				if (data == 0) {
					saveContractReport(mFile);
				} else {
					alert("编辑合同失败");
				}
			},
			error : function(XMLHttpRequest, textStatus, errorThrown) {
			}
		});
	}
	
	function saveContractReport(tFile) {
		setTimeout(function() {
			//保存到数据库
			$.ajax({
				url : host + "/createProjectReport",
				type : 'POST',
				data : {
					"contactDate" : "",
					"userId" : tUploadFileInfo.split("#")[1],
					"reportDesc" : tUploadFileInfo.split("#")[0],
					"projectId" : tUploadFileInfo.split("#")[2],
					"reportType" : 97,
					"fileName" : tFile.name,
					"caseId" : ""
				},
				cache : false,
				async : false,
				success : function(returndata) {
					var data = eval("(" + returndata + ")").errcode;
					if (data == 0) {
						alert("提交成功");
						closeConfirmBox();
						getContractList(page);
					} else {
						alert("提交失败");
					}
				},
				error : function(XMLHttpRequest, textStatus, errorThrown) {
				}
			});
		}, 500);
	}
	
	//获取分片文件
	function getSliceFile(mFile, tChunk) {
		var start = tChunk * sliceSize;
		var end = Math.min(start + sliceSize, mFile.size);
		var slice = File.prototype.slice || File.prototype.mozSlice
				|| File.prototype.webkitSlice;
		var sliceFile = slice.call(mFile, start, end);
		return sliceFile;
	}

	function upDateProgress(currentChunk) {
		var percent = Math.round((currentChunk + 1) * 100 / chunks);
		var cont = document.getElementById("progress");
		cont.innerHTML = percent.toFixed(2) + '%';
		cont.style.width = percent.toFixed(2) + '%';
	}
	
	function getProjectReport(tProjectId) {
		var fileName = "";
		$.ajax({
			url : host + "/projectReportList",
			type : 'GET',
			data : {
				"projectId" : tProjectId
			},
			cache : false,
			async : false,
			success : function(returndata) {
				var data2 = eval("(" + returndata + ")").prList;
				for ( var i in data2) {
					var reportType = data2[i].reportType;
					if (reportType == 97) {
						fileName = data2[i].fileName;
						break;
					}
				}
			},
			error : function(XMLHttpRequest, textStatus, errorThrown) {
			}
		});
		return fileName;
	}
	
	
	function downloadContarct(fileName, projectId) {
		$.ajax({
			url : host + "/downloadFile",
			type : 'GET',
			data : {
				"fileName" : fileName,
				"reportType" : 97,
				"projectId" : projectId,
				"createYear" : ""
			},
			cache : false,
			async : false,
			success : function(returndata) {
				var errcode = eval("(" + returndata + ")").errcode;
				if (errcode == 0) {
					var link = document.createElement("a");
					link.href = eval("(" + returndata + ")").fileLink;
					document.body.appendChild(link).click();
				} else {
					var msg = eval("(" + returndata + ")").errmsg;
					alert(msg);
				}

			},
			error : function(XMLHttpRequest, textStatus, errorThrown) {
			}
		});
	}
	
	function changeCompany(tCompanyId) {
		var salesId = getProjectList(tCompanyId);
		getSaleUserList();
		if (salesId != 0) {
			$("#salesId").val(salesId);
		}
	}

	function getProjectList(tCompanyId) {
		var mSalesId;
		$.ajax({
			url : "${pageContext.request.contextPath}/projectList",
			type : 'GET',
			data : {
				"companyId" : tCompanyId,
				"projectName" : "",
				"salesId" : 0,
				"projectManager" : 0
			},
			cache : false,
			async : false,
			success : function(returndata) {
				var data2 = eval("(" + returndata + ")").projectList;
				var str = '<option value="0">请选择...</option>';
				if (data2.length > 0) {
					mSalesId = data2[0].salesId;
				} else {
					mSalesId = 0;
				}
				for ( var i in data2) {
					str += '<option value="'+data2[i].projectId+'">'
							+ data2[i].projectName + '</option>';
				}
				$("#projectId").empty();
				$("#projectId").append(str);

			},
			error : function(XMLHttpRequest, textStatus, errorThrown) {
			}
		});
		return mSalesId;
	}

	
	function getProject(mProjectId) {
		var projectName;
		$
				.ajax({
					url : "${pageContext.request.contextPath}/getProjectByProjectId",
					type : 'GET',
					data : {
						"projectId" : mProjectId
					},
					cache : false,
					async : false,
					success : function(returndata) {
						projectName = eval("(" + returndata + ")").project[0].projectName;
					},
					error : function(XMLHttpRequest, textStatus, errorThrown) {
					}
				});
		return projectName;
	}

	function getCompany(mCompanyId) {
		var companyName;
		$
				.ajax({
					url : "${pageContext.request.contextPath}/getCompanyByCompanyId",
					type : 'GET',
					data : {
						"companyId" : mCompanyId
					},
					cache : false,
					async : false,
					success : function(returndata) {
						companyName = eval("(" + returndata + ")").company[0].companyName;
					},
					error : function(XMLHttpRequest, textStatus, errorThrown) {
					}
				});
		return companyName;
	}

	function getUser(uId) {
		var userName;
		$.ajax({
			url : "${pageContext.request.contextPath}/getUserById",
			type : 'GET',
			data : {
				"uId" : uId
			},
			cache : false,
			async : false,
			success : function(returndata) {
				userName = eval("(" + returndata + ")").user[0].name;
			},
			error : function(XMLHttpRequest, textStatus, errorThrown) {
			}
		});
		return userName;
	}
	
	function getUserInfo(uNickName) {
		var mUid;
		$.ajax({
			url : "${pageContext.request.contextPath}/getUserByNickName",
			type : 'GET',
			async : false,
			data : {
				"nickName" : uNickName
			},
			cache : false,
			success : function(returndata) {
				var data = eval("(" + returndata + ")").user;
				mUid = data[0].UId;
			}
		});
		return mUid;
	}

	function nextPage() {
		if (page == lastPage) {
			alert("已经是最后一页");
			return;
		} else {
			page++;
			getContractList(page);
		}
	}

	function previousPage() {
		if (page == 1) {
			alert("已经是第一页");
			return;
		} else {
			page--;
			getContractList(page);
		}
	}

	function FirstPage() {
		if (page == 1) {
			alert("已经是首页");
			return;
		} else {
			page = 1;
			getContractList(page);
		}
	}

	function LastPage() {
		if (page == lastPage) {
			alert("已经是尾页");
			return;
		} else {
			page = lastPage;
			getContractList(page);
		}
	}
	
	function confirmDelete(id) {
		$(".banDel").show();
		deleteId = id;
	}
    
	function deleteContract() {
		$.ajax({
			url : "${pageContext.request.contextPath}/deleteContract",
			type : 'POST',
			data : {
				"id" : deleteId
			},
			cache : false,
			async : false,
			success : function(returndata) {
				var data = eval("(" + returndata + ")").errcode;
				if (data == 0) {
					alert("删除成功");
					setTimeout(function() {
						location.reload();
					}, 500);

				} else {
					alert("删除失败");
				}

			},
			error : function(XMLHttpRequest, textStatus, errorThrown) {
			}
		});
	}

	function getPurchaseInfo(cNum) {
		alert(cNum);
		
		
		/* var mHtml = '<div style="margin-top:10px;width:100%"><label><Strong>项目编号：</Strong>'
				+ arrayProjectNum[pNum]
				+ '</label></div><br/>'
				+ '<div style="margin-top:10px;width:100%"><label><Strong>项目名称：</Strong>'
				+ arrayProjectName[pNum]
				+ '</label></div><br/>'
				+ '<div style="margin-top:10px;width:100%"><label><Strong>是否需要采购：</Strong></label></div>'
				+ '<input type="radio" name="field002" disabled="disabled"/>是'
				+ '<input type="radio" name="field002" disabled="disabled" style="margin-left:100px;"/>否'
				+ '<div style="margin-top:5px;width:100%"><label><Strong>采购明细：</Strong></label><label style="color:red">设备序列号&nbsp-&nbsp设备型号&nbsp-&nbsp设备数量&nbsp-&nbsp预估到货时间&nbsp-&nbsp实际到货时间</label></div><br/>'
				+ '<div style="width:100%"><textarea id="purchaseDetails" style="resize: none; width: 98%; height: 92px; margin-top:5px"></textarea></div><br/>'

		swal({
			title : '采&nbsp&nbsp购&nbsp&nbsp信&nbsp&nbsp息',
			html : mHtml,
			showCloseButton : true,
			showConfirmButton : false,
			allowOutsideClick : false,
		}) */
	}
</script>

</head>
<body>
	<div id="pageAll">
		<div class="pageTop">
			<div class="page">
				<img src="../image/coin02.png" /><span><a href="#">首页</a>&nbsp;-&nbsp;<a
					href="#">合同管理</a>&nbsp;-</span>&nbsp;合同信息管理
			</div>
		</div>

		<div class="page">
			<!-- vip页面样式 -->
			<div class="vip">
				<div class="conform">
					<form style="width: 100%">
						<div class="cfD" style="width: 100%">
							<Strong style="margin-right: 20px">查询条件：</Strong> <label
								style="margin-right: 10px">客户名称：</label><select class="selCss"
								style="width: 25%" id="companyId"
								onChange="changeCompany(this.options[this.options.selectedIndex].value)" /></select>
							<label style="margin-right: 10px">项目名称：</label><select
								class="selCss" style="width: 25%" id="projectId">
								<option value="0">请选择...</option>
							</select>

						</div>
						<div class="cfD" style="width: 100%">
							<label style="margin-left: 114px; margin-right: 10px">销售人员：</label><select
								class="selCss" style="width: 25%" id="salesId"></select> <label
								style="margin-left: 20px">合同编号：</label><input type="text"
								class="input3" placeholder="输入合同编号" style="width: 24%"
								id="contractNum" />
						</div>
						<div class="cfD">
							<label style="margin-left: 86px;">合同实施日期：</label><input
								type="text" id="date1" style="width: 8%" class="input3"
								placeholder="0000/00/00"/> <span id="dd"></span><Strong
								style="margin-left: 15px; margin-right: 10px">至</Strong> <input
								type="text" id="date2" style="width: 8%" class="input3"
								placeholder="0000/00/00"/> <span id="dd2"></span> <a
								class="addA" href="#" onClick="toCreateContractPage()"
								style="margin-left: 40px">新建合同信息+</a><a class="addA"
								onClick="getContractList(1)">搜索</a>
						</div>

					</form>
				</div>
				<!-- vip 表格 显示 -->
				<div class="conShow">
					<table border="1" style="width: 100%">
						<tr style="width: 100%">
							<td style="width: 14%" class="tdColor">合同编号</td>
							<td style="width: 28%" class="tdColor">项目名称 / 客户名称</td>
							<td style="width: 10%" class="tdColor">销售人员</td>
							<td style="width: 10%" class="tdColor">合同上传</td>
							<td style="width: 20%" class="tdColor">合同实施日期</td>
							<td style="width: 10%" class="tdColor">交货收款信息</td>
							<td style="width: 8%" class="tdColor">操作</td>
						</tr>

					</table>
					<table id="tb" border="1" style="width: 100%">
					</table>
					<div class="paging" style="margin-top: 20px; margin-bottom: 50px;">
						<input type="button" class="submit" value="首页"
							style="margin-left: 10px; width: 60px;" onclick="FirstPage()" />
						<input type="button" class="submit" value="上一页"
							style="margin-left: 10px; width: 60px;" onclick="previousPage()" />
						<input type="button" class="submit" value="下一页"
							style="margin-left: 10px; width: 60px;" onclick="nextPage()" />
						<input type="button" class="submit" value="尾页"
							style="margin-left: 10px; width: 60px;" onclick="LastPage()" />
						<span style="margin-left: 10px;">当前页：</span> <span id="p">0/0</span>
					</div>
				</div>
				<!-- vip 表格 显示 end-->
			</div>
			<!-- vip页面样式end -->
		</div>

	</div>

<!-- 上传投标文件弹出框 -->
	<div class="banDel" id="banDel2">
		<div class="delete" style="width: 600px">
			<div class="close">
				<a><img
					src="${pageContext.request.contextPath}/image/shanchu.png"
					onclick="closeConfirmBox()" /></a>
			</div>
			<p class="delP1">上传合同文件</p>
			<p class="delP2" style="margin-top: 10px;">
				<label style="font-size: 16px;">上传附件：</label><input type="file"
					name="myfile" id="myfile"
					style="width: 410px; margin-top: 15px; margin-left: 10px; border: none;"
					accept="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet, application/vnd.ms-excel,application/vnd.ms-powerpoint,application/msword,image/*,application/pdf,application/x-zip-compressed,application/x-rar-compressed,.docx,.rar" />
			</p>

			<p class="delP2" style="text-align: center; margin-top: 15px;">
				<label style="font-size: 16px; color: brown">所有合同文件请打包成一个文件上传</label><br />
			</p>

			<p class="delP2" style="height: 20px;">
			<div id="progressDiv"
				style="width: 500px; height: 20px; background-color: gray; margin-left: 50px;">
				<span id="progress"
					style="display: inline-block; height: 20px; background-color: orange; line-height: 20px; text-align: left; float: left"></span>
			</div>
			</p>

			<p class="delP2" style="margin-top: 40px;">
				<a class="addA" href="#" onclick="addContractReport()"
					style="margin-left: 0px; margin-bottom: 30px;">提交</a><a
					class="addA" href="#" onclick="closeConfirmBox()">取消</a>
			</p>
		</div>
	</div>
</body>
</html>