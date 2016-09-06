
#CoreBluetoothPlusSDK 开发文档
===========
本文档为 `CoreBluetoothPlusSDK` 开发文档, 用于解释 SDK 架构, 以及相关通讯协议. 架构图如下, 可以打开连接, 格式为 `xmind 文件`
[![架构导图]](./HXBluetoothSDK.xmind)

****** 
|      		|  				  		|
| :-------:	|:--------------------:	|
| 版本号:	  | V1.0					| 
| 作者:	   | huangxiong			|
| 联系方式:	  | huangxionging@qq.com	|
| 日期:	   |  2016.04.14			 |	
|	===		 |	====					|
******
##<a name="index"/>目录
* [一. SDK 架构](#structure)
	* 架构
* [二. SDK 基类](#baseClass)
* [三. 纬科联蓝牙](#wkl)
	*	3.1  [同步参数指令(synchronize parameter)](#synchronize parameter)
	*	3.2
	*	3.3
	*	3.4
	*	3.5
	*	3.6
	*	3.7
	*	3.8
	*	3.9
	*	3.10
	*	3.11
	*	3.12
	*	3.13
	*	3.14 简单
* [四. 纬科联蓝牙模块通讯接口](#protocol)
	*	4.1 [查询绑定状态](#check_bind_state)
	*	4.2 [申请绑定设备](#apply_bind_device)
	*	4.3 [确认绑定设备](#confirm_bind_device)
	*	4.4 [删除绑定设备](#cancel_bind_device)
	*	4.5 [同步参数](#synchronize_parameter)
	*	4.6 [设置计步数据保存时间间隔](#set_pedometer_data_save_time_interval)
	*	4.7 [同步计步数据](#synchronize_step_data)
	*	4.8 [同步睡眠数据](#synchronize_sleep_data)
	*	4.9 [查询设备版本](#query_device_version)


##<a name="structure"/> SDK 架构





##<a name="baseClass"/> SDK 基类

##<a name="protocol"/> 四. 纬科联蓝牙模块通讯接口

	调用方式: "ble://接口?参数=值&参数=值"
	接口必须有, 参数看具体的接口
***
*	4.1 <a name="check_bind_state"> _查询绑定状态_<br>

		接口名称: check_bind_state
		
		参数: 无
***

*	4.2 <a name="apply_bind_device"> _申请绑定设备_
	
		接口名称: apply_bind_device.
	
		参数: 无.
		
		返回值: 
			code:	0 表示允许APP绑定,需要等待; 
					1 表示绑定失败, 设备不允许绑定;
					2 表示绑定失败, 设备被其他手机绑定了.
			time:	只在 code 为 0 时有效, 表示时延,单位为秒; 若APP在超出此时 间后仍没有收到
					设备发出的确认结果,则绑定失败.

			
***

*	4.3 <a name="confirm_bind_device"> _确认绑定设备_
	
		接口名称: confirm_bind_device.
		
		参数: 无.
		
		返回值:
			code:	0 表示完成绑定;
					1 表示绑定失败.
***

*	4.4 <a name="cancel_bind_device"> _删除绑定设备_
	
		接口名称: cancel_bind_device.
		
		参数: 
			action_type: 表示附加操作类型, 0:无指定的附加操作,由设备自行决定;1:重启设备;2:清除所有数据;3:清除所有数据并重启设备.
			
		返回值:
			code: 0 表示解除绑定成功; 1表示解除绑定失败.
***
*	4.5 <a name="synchronize_parameter"> _同步参数_<br>
		
		接口名称: synchronize_parameter.
		
		参数: 
			step_goal: 运动目标, 单位为 100步的倍数, 比如 10 表示 1000步; (必须)
			wear_type: 设备的配戴位置,依次为:1手腕(默认),2脖子,3腰,4脚; (可选)
			sport_type: 运动类型, 1步行(默认), 2睡觉, 3骑车, 4游泳, 5网球, 6篮球, 7足球;(可选)
			synchronize_flag: 同步标识, 0 表示表示第一次同步, 1 表示不是第一次同步; (必须)
			gender_type: 性别, 0 表示男性, 1 表示女性;(必须)
			age: 年龄 0~17 范围內;(必须)
			weight: 体重, 单位 kg, 0 表示原来设置的不变; (可选)
			height: 身高, 单位为 cm, 0 表示原来的设置不变; (可选)
			measure: 度量, 0 表示公制(默认), 1 表示英制; (可选)
			disconnect_remind: 蓝牙断连提醒, 0 表示关闭提醒功能(默认), 1 表示打开提醒功能. (可选)
			
		返回值:
			device_id: 表示设备编号, 16 位编码;
			protocol_version: 通讯协议版本;
			upgraded_type: 升级方式, 0 表示无特殊功能, 1 表示 Quintic OTA Profile升级固件,  2 表示 Dialog 自定义的升级固件;
			firmware_version: 固件版本, 值越大表示固件越新;
			device_type: 设备类型, ascii 字符.
			
***

*	4.6 <a name="set_pedometer_data_save_time_interval"> _设置计步数据保存时间间隔_

		接口名称: set_pedometer_data_save_time_interval.
		
		参数:
			time_interval: 计步数据分片存储的时间间隔, 每个时间段存储一条数据. 单位为分钟, 默认为30, 最小为10。本字段为 0 表示原设置不变.(可选)
			
		返回值:
			code: 0 表示设置成功, 1 表示设置失败.

***
*	4.7 <a name="synchronize_step_data">_同步计步数据_

		接口名称: synchronize_step_data.
		
		参数:
			start_date: 起始日期, 例子: 20160901;(必须)
			end_date: 结束日期, 例子: 20160901.(必须)
		
		返回值:
			{
				total_count: 有效天数;
				all_day_step_data: [ // 所有有记录的天数的运动数据
					{
						date: 日期;
						time_interval: 间隔;
						step_count: 该天总步数;
						step_data: [
							time: 时间;
							steps: 该段时间的总步数;
						];
						...
					};
					...
				];
			}
			 
***
*	4.8 <a name="synchronize_sleep_data">_同步睡眠数据_

		接口名称: synchronize_sleep_data.
		
		参数:
			start_date: 起始日期, 例子: 20160901;(必须)
			end_date: 结束日期, 例子: 20160901.(必须)
		
		返回值:
			{
				total_count: 有效天数;
				all_day_sleep_data: [ // 所有有记录的天数的运动数据
					{
						date: 日期;
						sleep_count: 条数;
						sleep_total_time: 该天总睡眠时长;
						sleep_data: [
							start_minute: 起始时间, 单位分钟 从00:00开始算, 取值 0~1439;
							sleep_minute: 睡眠持续时长, 单位分钟, 取值 5~240, 超过 240 分钟多条;
							sleep_flag: 睡眠标志, 0~5, 值越小表示睡眠质量越好
						];
						...
					};
					...
				];
			}	

***
*	4.9 [查询设备版本](#query_device_version)
[架构导图]:HXBluetooth.png "架构导图"