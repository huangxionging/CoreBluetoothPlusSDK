
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
	*	4.1	[查询绑定状态](#check_bind_state)
	*	4.2 [申请绑定设备](#apply_bind_device)
	*	4.3 [确认绑定设备](#confirm_bind_device)
	*	4.4 [删除绑定设备](#cancel_bind_device)
	*	4.5 [同步参数](#synchronize_parameter)
	*	4.6 [设置计步数据保存时间间隔](#set_pedometer_data_save_time_interval)
	*	4.7 [同步计步数据](#synchronize_step_data)
	*	4.8 [同步睡眠数据](#synchronize_sleep_data)
	*	4.9 [查询设备版本](#query_device_version)
	*	4.10[固件升级](#firmware_upgrade)
	*	4.11[重启设备](#restart_device)
	*	4.12[设置水杯参数](#setting_cups_parameter)
	*	4.13[查询水杯状态](#check_cups_state)
	*	4.14[同步饮水数据](#synchronize_drink_water_data)
	*	4.15[同步饮水计划](#synchronize_drink_water_plan)
	*	4.16[点亮 led 灯](#light_led)
	*	4.17[蜂鸣器响](#buzzer_sound)
	*	4.18[防丢](#anti_lost)
	*	4.19[按键锁](#key_lock)
	*	4.20[改变颜色](#change_color)
	*	4.21[查找设备](#search_device)
	*	4.22[ANCS 功能开关](#ancs_switch)
	*	4.23[查询设备工作状态](#check_device_working_state)
	*	4.24[查询电池电量](#check_battery_power)
	*	4.25[查询设备序号](#check_device_serial)
	*	4.26[设置设备序号](#set_device_serial)
	*	4.27[调试信息](#debug_info)
	*	4.28[来电提醒姓名](#call_remind_name)
	*	4.29[心率功能设置](#heart_rate_feature)
	*	4.30[宠物运动参数设置](#pet_motion_parameter)
	*	4.31[查询一天的总步数](#check_one_day_total_steps)
	*	4.32[查询设备当前时间](#check_device_current_time)
	*	4.33[体温功能设置](#temperature_function)
	*	4.34[APP 前后台状态](#app_front_and_back_state)
	*	4.35[设备调试信息](#device_debug_info)
	*	4.36[设备当天总步数](#device_current_steps)
	*	4.37[设备心率](#device_heart_rate)
	*	4.38[设备电量](#device_battery_power)
	*	4.39[设备体温](#device_temperature)


##<a name="structure"/> SDK 架构





##<a name="baseClass"/> SDK 基类

##<a name="protocol"/> 四. 纬科联蓝牙模块通讯接口

```Objective-c
// 调用方式: "ble://接口?参数=值&参数=值"
// 接口必须有, 参数看具体的接口

// 设置参数
NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity: 5];
[parameter setObject: @"parameterValue1" forKey: @"parameterKey1"];
[parameter setObject: @"parameterValue2" forKey: @"parameterKey2"];
...

// 参数可直接拼在接口后面, 也可传参
[self.manager post: @"ble://接口?参数=值&参数=值" parameters: parameter success:^(CBPBaseAction *action, id responseObject) {
	NSLog(@"%@", responseObject);
    NSLog(@"%@", parameter);
} failure:^(CBPBaseAction *action, CBPBaseError *error) {
        
}];
```
***
* 4.1 <a name="check_bind_state"> *查询绑定状态*<br>

		接口名称: check_bind_state
		
		参数: 无
		
***
*	4.2 <a name="apply_bind_device"> *申请绑定设备*
	
		接口名称: apply_bind_device.
	
		参数: 无.
		
		返回值: 
			code:	0 表示允许APP绑定,需要等待; 
					1 表示绑定失败, 设备不允许绑定;
					2 表示绑定失败, 设备被其他手机绑定了.
			time:	只在 code 为 0 时有效, 表示时延,单位为秒; 若APP在超出此时 间后仍没有收到
					设备发出的确认结果,则绑定失败.

			
***
*	4.3 <a name="confirm_bind_device"> *确认绑定设备*
	
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
			device_id: 表示设备编码;
			protocol_version: 通讯协议版本;
			upgrade_type: 升级方式, 0 表示无特殊功能, 1 表示 Quintic OTA Profile升级固件,  2 表示 Dialog 自定义的升级固件;
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
			start_date: 起始日期, 例子: 2016-09-01;(必须)
			end_date: 结束日期, 例子: 2016-09-01.(必须)
			
		进度:
			progress 同步进度会返回多次;
		
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
			start_date: 起始日期, 例子: 2016-09-01;(必须)
			end_date: 结束日期, 例子: 2016-09-01.(必须)
			
		进度:
			progress 同步进度会返回多次;
		
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
*	4.9 <a name="query_device_version">_查询设备版本_
	
		接口名称: query_device_version.
		
		参数: 无
		
		返回值:
			device_id: 表示设备编码;
			protocol_version: 通讯协议版本;
			upgrade_type: 升级方式, 0 表示无特殊功能, 1 表示 Quintic OTA Profile升级固件,  2 表示 Dialog 自定义的升级固件, 3 表示 Cypress 升级;
			firmware_version: 固件版本, 值越大表示固件越新;
			device_type: 设备类型, ascii 字符.
			
***
*	4.10 <a name="firmware_upgrade">_固件升级_
	
		接口名称: firmware_upgrade.
		
		参数:
			upgrade_type: 升级方式, 0 表示普通升级, 1 表示 Quintic OTA Profile升级固件,  2 表示 Dialog 自定义的升级固件, 3 表示 Cypress 升级;
			file_path: 文件路径(包含扩展名);
			
		进度:
			progress 升级进度会返回多次;
			
		返回值: 
			code: 0 表示升级成功, 1 表示升级失败;
			
			
				

***
*	4.11 <a name="restart_device">_重启设备_
	
		接口名称: restart_device
		
		参数:
			content_type: 内容, 需要恢复的内容, 其中
				0:恢复全部参数为出厂设置,并重启;				1:仅重启设备;				2:查询已存储的上一条指令的执行结果(“回传”字段固定为 0);				3:清除计步数据;				4:清除睡眠数据;			response: 回传, 其中 0:不需要回传, 1:需要回传
		返回值:			result: 0:接收到指令, 1:仅重启完成, 2:指令执行正常完成, 3:指令执行失败
			
****	4.12 <a name="setting_cups_parameter">_设置水杯参数_
		接口名称: setting_cups_parameter
		参数: 			time: 年月日时分秒, 格式: 2016-09-07 15:35:30;
			led_remind: 0 表示允许 led 提醒, 1 表示关闭 led 提醒;
			buzzer_remind: 0 表示允许蜂鸣器提醒, 1 表示关闭蜂鸣器提醒;
			valid: 0 表示本次修改无效, 1 表示本次修改有效					返回值:
			code: 0 表示设置成功, 1 表示不成功***
*	4.13 <a name="check_cups_state">_查询水杯状态_

		接口名称: check_cups_state
		参数: 无
		
		返回值:
			water_temperature: 水温度值, 单位为摄氏度;
			water_intake: 当天饮水量, 单位为 ml;
			cup_capacity: 水杯容量, 单位 ml, -1为未知;
			cup_of_water: 杯内水量, 单位 ml;
			final_water_intake: 最后饮水量, 单位 ml, 0 表示没有饮水;
			final_water_time: 最后饮水时间, 单位为分钟, 若当天没有饮水, 则为0.
			state: 0 表示未重新上电, 1 表示重新上电. 重新上电标志表示水杯刚更换过电池,或者因电量不足、接触不良等原因导致电路重启,APP 在收到此标志后应弹出提示,并启动一次校准流程。设备收到校准指令后清除本标志
***
*	4.14 <a name="synchronize_drink_water_data">_同步饮水数据_
	
	接口名称: synchronize_drink_water_data.
		
		参数:
			start_date: 起始日期, 例子: 2016-09-01 16:33;(必须)
			end_date: 结束日期, 例子: 2016-09-01 16:34.(必须)
		
		返回值:
			{
				total_count: 有效天数;
				all_day_drink_water_data: [ // 所有有记录的天数的运动数据
					{
						date: 日期;
						drink_water_count: 条数;
						drink_water_total_intake: 该天总饮水量;
						drink_water_data: [
							start_minute: 喝水起始时间, 单位分钟 从00:00开始算, 取值 0~1439;
							drink_water_intake: 饮水量, 从起始时刻开始,10 分钟内饮水的总量为一条数据.
						];
						...
					};
					...
				];
			}	


***
*	4.15 <a name="synchronize_drink_water_plan">_同步饮水计划_

		接口名称: synchronize_drink_water_plan.
		
		参数:
			serial_count: 需要同步的条数
		
		返回值:
		***	*	4.16 <a name="light_led"> *点亮 led 灯*
		接口名称: light_led.
		
		参数:
			led: 4字节16进制构成的字符串, 表示32个开关, 例子 @"0xffff02fe", 每一位开关 0 表示开, 1表示灭;
			light_on_time: 亮时长, 10 ms 为最小单位;
			light_off_time: 灭时长, 10 ms 为最小单位;
			repeat_count: 重复次数;
			
		
		返回值:
			led_state: 指LED开关对应位的LED是否已按参数开始工作。0:表示未受控制,1:表示已受控制。
***	
*	4.17 <a name="buzzer_sound"> *蜂鸣器响*

		接口名称: buzzer_sound.
		
		参数:
			switch: 蜂鸣器开关, 0 表示关闭蜂鸣器, 1 表示打开蜂鸣器响;
			duration_time: 持续时间, 单位为1ms,关闭蜂鸣器时,本字段无效;
			frequency: 蜂鸣器鸣叫音的频率, 单位为Hz. 若设备不支持调整频率, 则本字段无效. 若超出蜂鸣器的工作频率范围,则使用默认频率. 关闭蜂鸣器时, 本字段无效.
		
		返回值:
			state: 表示蜂鸣器工作状态, 0 表示不叫, 1 表示正在叫.
			
***
*	4.18 <a name="anti_lost">_防丢_

		接口名称: anti_lost.
		
		参数:
			switch: 0 表示关闭防丢提示, 1 表示打开防丢提醒, 设备根据预设参数发出提醒 (蜂鸣器鸣叫, LED闪烁等);
			duration_time: 提醒持续的时间长度, 单位为 1 ms. 关闭防丢提醒时, 本字段无效.

		返回值:
			state: 表示防丢提醒状态, 0 表示已停止提醒, 1 表示正常提醒, 2 表示出错.
***
*	4.19 <a name="key_lock">_按键锁_	
	
		接口名称: key_lock. 在指定的时间内, 按下按键后将向手机发送控制指令; 达到指令时间后, 自动退出锁定模式.
		
		参数:
			switch: 0 表示退出按键锁定模式, 1 表示进入按键锁定模式;
			duration_time: 提醒持续的时间长度, 单位为秒. 取值为5~600,超出此范围时, 取最接的最大或最小值, 退出锁定模式时, 本字段无效.

		返回值:
			state: 表示防丢提醒状态, 0 表示已停止提醒, 1 表示正常提醒, 2 表示出错.
			
***
*	4.20 <a name="change_color">_改变颜色_	
	
		接口名称: change_color. 
		
		参数:
			color_value: 0-蓝, 1-橙, 2-绿, 3-红;

		返回值:
			state: 更换三基色灯操作结果, 0-成功, 1-出错.
***
*	4.21 <a name="search_device">_查找设备_	
	
		接口名称: search_device.
				
		参数: 无
		
		返回值: 无
***
*	4.22 <a name="ancs_switch">_ANCS 功能开关_	
	
		接口名称: ancs_switch.
				
		参数:
			switch: 1 表示打开(使能)ANCS功能, 0 表示关闭.
		
		返回值: 无
***
*	4.23 <a name="check_device_working_state">_查询设备工作状态_	
	
		接口名称: check_device_working_state.
				
		参数: 无
		
		返回值:
			bluetooth_state: 蓝牙状态, 0 表示正在通讯, 1 表示工作异常, 2, 表示无此功能, 3 表示;
			gravity_sensor_percussion_interrupt : 重力传感器敲击中断, 0 表示正在检测中, 1 表示工作异常, 2, 表示无此功能;
			gravity_sensor_motion_interrupt: 重力传感器运动中断, 0 表示正在检测中, 1 表示工作异常, 2, 表示无此功能;
			gravity_sensor_communication_state: 重力传感器通讯状态, 0 表示正在通讯中, 1 表示工作异常, 2, 表示无此功能;
			supply_voltage_detection: 供电电压检测, 0 表示正在检测中, 1 表示电压不在预定范围内, 2, 表示无此功能;
			charge_detection: 充电检测: 01 表示正在检测中, 1 表示超时未检测到开始充电(可选), 2, 表示无此功能;
			gravity_sensor_triaxial_data_change: 重力传感器三轴数据变化, 0001 表示正在检测中, 1xyz: XYZ 轴数据在检测过程中是否曾经有变 化:有变化的位为 1,无变化为 0,全为 1 表示 数据变化正常。
			external_flash_rw_operation: 001 表示正在检测中 1rw 表示读写操作的结果, 1 表示操作 成功,0 表示失败. (r:读, w:写).
			
***

*	4.24 <a name="check_battery_power"> _查询电池电量_
	
		接口名称: check_battery_power.
		
		参数: 无
		
		返回值: 
			battery_power: 电量百分比 0~100;
***

*	4.25 <a name="check_device_serial"> _查询设备序号_
	
		接口名称: check_device_serial.
		
		参数: 无
		
		返回值: 
			device_serial: 设备序号;
***

	*	4.26[设置设备序号](#set_device_serial)
	*	4.27[调试信息](#debug_info)
	*	4.28[来电提醒姓名](#call_remind_name)
	*	4.29[心率功能设置](#heart_rate_feature)
	*	4.30[宠物运动参数设置](#pet_motion_parameter)
	*	4.31[查询一天的总步数](#check_one_day_total_steps)
	*	4.32[查询设备当前时间](#check_device_current_time)
	*	4.33[体温功能设置](#temperature_function)
	*	4.34[APP 前后台状态](#app_front_and_back_state)
	*	4.35[设备调试信息](#device_debug_info)
	*	4.36[设备当天总步数](#device_current_steps)
	*	4.37[设备心率](#device_heart_rate)
	*	4.38[设备电量](#device_battery_power)
	*	4.39[设备体温](#device_temperature)

	
[架构导图]:HXBluetooth.png "架构导图"