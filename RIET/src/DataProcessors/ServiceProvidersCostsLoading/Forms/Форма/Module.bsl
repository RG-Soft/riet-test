&НаКлиенте
Перем СоответствиеСинонимовИимен;

//////////////////////////////////////////////////////////////////////////////////////
// СОБЫТИЯ ФОРМЫ

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ВыбратьФайл();
	ЗаполнитьСписокЛистовЭкселяИНомераКолонок();
	ЗаполнитьПараметрыСтруктурыФайлаПоУмолчанию();
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьПараметрыСтруктурыФайлаПоУмолчанию()
	
	FirstRowOfData = 2;
	LastRowOfData = 0;
	
КонецПроцедуры


//////////////////////////////////////////////////////////////////////////////////////
// ВЫБОР ФАЙЛА

&НаКлиенте
Процедура FullPathНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ВыбратьФайл();
	ЗаполнитьСписокЛистовЭкселяИНомераКолонок();
	
КонецПроцедуры

&НаКлиенте
Процедура ВыбратьФайл()
	
	ДиалогВыбораФайла = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	
	ДиалогВыбораФайла.Фильтр						= "Files xls (*.xls)|*.xls|Files xlsx (*.xlsx)|*.xlsx";
	ДиалогВыбораФайла.ПроверятьСуществованиеФайла	= Истина;
	
	Если ДиалогВыбораФайла.Выбрать() Тогда
		
		FullPath = ДиалогВыбораФайла.ПолноеИмяФайла;
		
	КонецЕсли;
		
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьСписокЛистовЭкселяИНомераКолонок()
	
	Sheet = "";
	СписокЛистов = Новый Массив;
	Если ЗначениеЗаполнено(FullPath) Тогда
		Connection = Новый COMОбъект("ADODB.Connection");
		СтрокаПодключения = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=" + FullPath + ";Extended Properties=""Excel 12.0;HDR=No;IMEX=1""";	
		Попытка 
			Connection.Open(СтрокаПодключения);	
		Исключение
			Попытка
				СтрокаПодключения = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + FullPath + ";Extended Properties=""Excel 8.0;HDR=No;IMEX=1""";
				Connection.Open(СтрокаПодключения);
			Исключение
				Сообщить(ОписаниеОшибки());
			КонецПопытки;
		КонецПопытки;
		rs = Новый COMObject("ADODB.RecordSet");
		rs.ActiveConnection = Connection;
		rs = Connection.OpenSchema(20);
		Пока rs.EOF() = 0 Цикл
			Если rs.Fields("TABLE_NAME").Value <> "_xlnm#_FilterDatabase" Тогда
				СписокЛистов.Добавить(rs.Fields("TABLE_NAME").Value);
			КонецЕсли;
			rs.MoveNext();
		КонецЦикла;
		rs.Close();
		Если СписокЛистов.Количество()>0 Тогда
			Sheet = СписокЛистов[0];
			sqlString = "Select top 1 * from [" + Sheet + "]";
			rs.Open(sqlString);
			ЗаполнитьНомераКолонок(rs);
			rs.Close();
		Конецесли;
		Connection.Close();
	КонецЕсли;
	Элементы.Sheet.СписокВыбора.ЗагрузитьЗначения(СписокЛистов);
	Если СписокЛистов.Количество() = 1 Или СписокЛистов.Количество() = 0 Тогда
		Элементы.Sheet.КнопкаСпискаВыбора = Ложь;
	Иначе
		Элементы.Sheet.КнопкаСпискаВыбора = Истина;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура SheetПриИзменении(Элемент)
	
	СписокЛистов = Новый Массив;
	Если ЗначениеЗаполнено(FullPath) Тогда
		Connection = Новый COMОбъект("ADODB.Connection");
		СтрокаПодключения = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=" + FullPath + ";Extended Properties=""Excel 12.0;HDR=No;IMEX=1""";	
		Попытка 
			Connection.Open(СтрокаПодключения);	
		Исключение
			Попытка
				СтрокаПодключения = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + FullPath + ";Extended Properties=""Excel 8.0;HDR=No;IMEX=1""";
				Connection.Open(СтрокаПодключения);
			Исключение
				Сообщить(ОписаниеОшибки());
			КонецПопытки;
		КонецПопытки;
		rs = Новый COMObject("ADODB.RecordSet");
		rs.ActiveConnection = Connection;
		sqlString = "select top 1 * from [" + Sheet + "]";
		rs.Open(sqlString);
		ЗаполнитьНомераКолонок(rs);
		rs.Close();
		Connection.Close();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьНомераКолонок(rs)
	
	Если rs.EOF <> 0 Тогда
		Возврат;
	КонецЕсли;
	
	Для ТекИндекс = 0 По rs.Fields.Count - 1 Цикл
		
		ИмяРеквизита = Неопределено;
		ИмяКолонки = СокрЛП(rs.Fields(ТекИндекс).Value);
		
		Для Каждого КлючИЗначение из СоответствиеСинонимовИимен Цикл 
			Если КлючИЗначение.Значение = ИмяКолонки Тогда 
				ИмяРеквизита = КлючИЗначение.Ключ;
				Прервать;
			КонецЕсли;  
		КонецЦикла;
		
		Если ИмяРеквизита <> Неопределено Тогда
			ЭтотОбъект[ИмяРеквизита] = ТекИндекс + 1;
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры


//////////////////////////////////////////////////////////////////////////////////////
// ЗАГРУЗКА

&НаКлиенте
Процедура Load(Команда)
	         	
	Если НЕ ЗначениеЗаполнено(FullPath) Тогда
		
		ВыбратьФайл();
		
		Если НЕ ЗначениеЗаполнено(FullPath) Тогда
			
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Need to select file!",
				, "Объект", "FullPath");
				Возврат;
			
		КонецЕсли;
		
	КонецЕсли;
	
	Если НЕ РГСофтКлиентСервер.ФайлДоступенДляЗагрузки(FullPath) Тогда
		Возврат;
	КонецЕсли;
	
	Если Не ВсеПоляУказаны() Тогда 
		Возврат;
	КонецЕсли;
		
	Отказ = Ложь;

		
	ЗаполнитьТаблицуДанныхИзФайлаXLS(Отказ, FullPath);
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
		
	Состояние("Updating data...");
	ЗаполнитьServiceProvidersCosts(Отказ);
	
	Если Отказ Тогда
		Сообщить("Failed to load service providers costs due to errors.
			|See them on the right pane.");
	Иначе
		Сообщить("Service providers costs were successfully loaded.");	
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Функция ВсеПоляУказаны()
	
	ВсеПоляУказаны = Истина;
	      		
	Если ColumnBaseCostsSum = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Need to specify the сolumn 'Base costs sum'!");
		ВсеПоляУказаны = Ложь;
	КонецЕсли;
	
	Если ColumnCurrency = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Need to specify the сolumn 'Currency'!");
		ВсеПоляУказаны = Ложь;
	КонецЕсли;
	
	Если ColumnDestinationLocationName = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Need to specify the сolumn 'Destination location name'!");
		ВсеПоляУказаны = Ложь;
	КонецЕсли;
	
	Если ColumnEquipmentCode = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Need to specify the сolumn 'Equipment code'!");
		ВсеПоляУказаны = Ложь;
	КонецЕсли;
	
	Если ColumnServiceProviderCode = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Need to specify the сolumn 'Service provider code'!");
		ВсеПоляУказаны = Ложь;
	КонецЕсли;
	
	Если ColumnSourceLocationName = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Need to specify the сolumn 'Source location name'!");
		ВсеПоляУказаны = Ложь;
	КонецЕсли;
	
	
	Возврат ВсеПоляУказаны;
	
КонецФункции

&НаКлиенте
Процедура ЗаполнитьТаблицуДанныхИзФайлаXLS(Отказ, ПолноеИмяXLSФайла)
	
	// Открываем файл
	Connection = Новый COMОбъект("ADODB.Connection");
	СтрокаПодключения = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=" + FullPath + ";Extended Properties=""Excel 12.0;HDR=No;IMEX=1""";	
	Попытка 
		Connection.Open(СтрокаПодключения);	
	Исключение
		// если подключение не удалось, то пытаемся подключиться к файлу через Microsoft.Jet.OLEDB.4.0
		Попытка
			СтрокаПодключения = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + FullPath + ";Extended Properties=""Excel 8.0;HDR=No;IMEX=1""";
			Connection.Open(СтрокаПодключения);
		Исключение
			Сообщить(ОписаниеОшибки());
		КонецПопытки;
	КонецПопытки;
	rs = Новый COMObject("ADODB.RecordSet");
	rs.ActiveConnection = Connection;
	rs = Connection.OpenSchema(20);
	//rs.MoveFirst(); // Станем на 1 закладку
	sqlString = "select * from [" + Sheet + "]";
	rs.Close();
	rs.Open(sqlString);
	
	rs.MoveFirst();
	
	// пропуск заголока
	rs.Move(FirstRowOfData - 1);
	
	АвтоОпределениеКонца = LastRowOfData = 0;
	НомерТекущейСтроки = FirstRowOfData;
	
	ТаблицаДанных.Очистить();
	
	//запоняем таб.документ пока не кончатся строки
	Пока ?(АвтоОпределениеКонца, rs.EOF = 0 И ЗначениеЗаполнено(rs.Fields(0).Value), НомерТекущейСтроки <= LastRowOfData) Цикл
		
		СтрокаТЗ = ТаблицаДанных.Добавить();
		
		СтрокаТЗ.EquipmentCode = СокрЛП(rs.Fields(ColumnEquipmentCode - 1).Value);
		СтрокаТЗ.Currency = СокрЛП(rs.Fields(ColumnCurrency - 1).Value);
		СтрокаТЗ.BaseCostsSum = СокрЛП(rs.Fields(ColumnBaseCostsSum - 1).Value);
		СтрокаТЗ.ServiceProviderCode = СокрЛП(rs.Fields(ColumnServiceProviderCode - 1).Value);
		СтрокаТЗ.SourceLocationName = СокрЛП(rs.Fields(ColumnSourceLocationName - 1).Value);
		СтрокаТЗ.DestinationLocationName = СокрЛП(rs.Fields(ColumnDestinationLocationName - 1).Value);
		СтрокаТЗ.НомерСтроки = НомерТекущейСтроки;
				
		rs.MoveNext();
		НомерТекущейСтроки = НомерТекущейСтроки + 1;
		
	КонецЦикла;
	
	rs.Close();
	Connection.Close();
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьServiceProvidersCosts(Отказ) 
	
	ЕстьОшибки = Ложь;
	НачатьТранзакцию(РежимУправленияБлокировкойДанных.Управляемый);
	
	Для Каждого ТекСтрока из ТаблицаДанных Цикл 
		
		SourceLocation = Справочники.Warehouses.НайтиПоНаименованию(ТекСтрока.SourceLocationName, Истина);
		Если Не ЗначениеЗаполнено(SourceLocation) Тогда
			Сообщить("Failed to find Source location by name <" + СокрЛП(ТекСтрока.SourceLocationName) + "> in line <" + СокрЛП(ТекСтрока.НомерСтроки) + ">.");
			ЕстьОшибки = Истина;
		КонецЕсли;
		
		DestinationLocation = Справочники.Warehouses.НайтиПоНаименованию(ТекСтрока.DestinationLocationName, Истина);
		Если Не ЗначениеЗаполнено(DestinationLocation) Тогда
			Сообщить("Failed to find Destination location by name <" + СокрЛП(ТекСтрока.DestinationLocationName) + "> in line <" + СокрЛП(ТекСтрока.НомерСтроки) + ">.");
			ЕстьОшибки = Истина;
		КонецЕсли;
		
		Equipment = Справочники.Equipments.НайтиПоКоду(ТекСтрока.EquipmentCode);
		Если Не ЗначениеЗаполнено(Equipment) Тогда
			Сообщить("Failed to find Equipment by code <" + СокрЛП(ТекСтрока.EquipmentCode) + "> in line <" + СокрЛП(ТекСтрока.НомерСтроки) + ">.");
			ЕстьОшибки = Истина;
		КонецЕсли;
		
		Запрос = Новый Запрос;
		Запрос.УстановитьПараметр("ServiceProviderCode", ТекСтрока.ServiceProviderCode);
		
		Запрос.Текст = "ВЫБРАТЬ
		|	ServiceProviders.Ссылка КАК ServiceProvider
		|ИЗ
		|	Справочник.ServiceProviders КАК ServiceProviders
		|ГДЕ
		|	ServiceProviders.Код = &ServiceProviderCode";
		
		МассивServiceProviders = Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("ServiceProvider");
		Если МассивServiceProviders.Количество() = 0 Тогда 
			Сообщить("Failed to find Service provider by code <" + СокрЛП(ТекСтрока.ServiceProviderCode) + "> in line <" + СокрЛП(ТекСтрока.НомерСтроки) + ">.");
			ЕстьОшибки = Истина;
		КонецЕсли;
		          		
		Currency = Справочники.Валюты.НайтиПоНаименованию(ТекСтрока.Currency);
		Если Не ЗначениеЗаполнено(Currency) Тогда
			Сообщить("Failed to find Currency <" + СокрЛП(ТекСтрока.Currency) + "> in line <" + СокрЛП(ТекСтрока.НомерСтроки) + ">.");
			ЕстьОшибки = Истина;
		КонецЕсли;

		Попытка
			BaseCostsSum = Число(ТекСтрока.BaseCostsSum);
		Исключение
			Сообщить("Failed to convert base cost sum to numeric <" + СокрЛП(ТекСтрока.BaseCostsSum) + "> in line <" + СокрЛП(ТекСтрока.НомерСтроки) + ">.");
			ЕстьОшибки = Истина;
		КонецПопытки;

		Если Не ЗначениеЗаполнено(BaseCostsSum) Тогда
			Сообщить("Sum is empty in line <" + СокрЛП(ТекСтрока.НомерСтроки) + ">.");
			ЕстьОшибки = Истина;
		КонецЕсли;
		
		Если ЕстьОшибки Тогда 
			Продолжить;
		КонецЕсли;
		
		Для Каждого ServiceProvider из МассивServiceProviders Цикл 
			
			МенеджерЗаписи = РегистрыСведений.ServiceProvidersCosts.СоздатьМенеджерЗаписи();
			МенеджерЗаписи.SourceLocation = SourceLocation;
			МенеджерЗаписи.DestinationLocation = DestinationLocation;
			МенеджерЗаписи.Equipment = Equipment;
			МенеджерЗаписи.ServiceProvider = ServiceProvider;
			МенеджерЗаписи.BaseCostsSum = BaseCostsSum;
			МенеджерЗаписи.Currency = Currency;	
			        				
			Попытка
				МенеджерЗаписи.Записать(Истина);
			Исключение
				Сообщить("Failed to save costs in line <" + СокрЛП(ТекСтрока.НомерСтроки) + ">:" + ОписаниеОшибки());
				ЕстьОшибки = Истина;
			КонецПопытки;
		
		КонецЦикла;
		
	КонецЦикла;	
	
	Если ЕстьОшибки Тогда 
		Отказ = Истина;
		ОтменитьТранзакцию();
	Иначе 
		ЗафиксироватьТранзакцию();
	КонецЕсли; 
	
КонецПроцедуры


СоответствиеСинонимовИимен = Новый Соответствие;
СоответствиеСинонимовИимен.Вставить("ColumnBaseCostsSum", "Base costs sum");
СоответствиеСинонимовИимен.Вставить("ColumnCurrency", "Currency");
СоответствиеСинонимовИимен.Вставить("ColumnDestinationLocationName", "Destination location name");
СоответствиеСинонимовИимен.Вставить("ColumnEquipmentCode", "Equipment code");
СоответствиеСинонимовИимен.Вставить("ColumnServiceProviderCode", "Service provider code");
СоответствиеСинонимовИимен.Вставить("ColumnSourceLocationName", "Source location name");


