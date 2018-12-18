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
	
	ДиалогВыбораФайла.Фильтр						= "Files xlsx (*.xlsx)|*.xlsx|Files xls (*.xls)|*.xls";
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
	
	Состояние("Loading data...");
	UpdateCatalogue();
	
	Сообщить("File was loaded.");
	
КонецПроцедуры

&НаКлиенте
Функция ВсеПоляУказаны()
	
	ВсеПоляУказаны = Истина;
	
	Если ColumnServiceProvider = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"Need to specify the сolumn 'Service provider'!");
		ВсеПоляУказаны = Ложь;
	КонецЕсли;
	
	Если ColumnEquipment = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"Need to specify the сolumn 'Equipment'!");
		ВсеПоляУказаны = Ложь;
	КонецЕсли;
	
	Если ColumnHours_a_day = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"Need to specify the сolumn 'Hours a day'!");
		ВсеПоляУказаны = Ложь;
	КонецЕсли;	
	
	Если ColumnMilage = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"Need to specify the сolumn 'Milage'!");
		ВсеПоляУказаны = Ложь;
	КонецЕсли;

	Если ColumnDate = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"Need to specify the сolumn 'Date'!");
		ВсеПоляУказаны = Ложь;
	КонецЕсли;
	
	Если ColumnCost = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"Need to specify the сolumn 'Cost'!");
		ВсеПоляУказаны = Ложь;
	КонецЕсли;
		
	Если ColumnCostPerDay = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"Need to specify the сolumn 'CostPerDay'!");
		ВсеПоляУказаны = Ложь;
	КонецЕсли;
	
	Если ColumnCostPerHour = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"Need to specify the сolumn 'CostPerHour'!");
		ВсеПоляУказаны = Ложь;
	КонецЕсли;
		
	
	Если ColumnCurrency = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"Need to specify the сolumn 'Currency'!");
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
	
	ТаблицаДанных.Очистить();
	
	//запоняем таб.документ пока не кончатся строки
	
	НомерСтроки = FirstRowOfData;
	БылиОшибки = Ложь;
	
	Пока rs.EOF = 0 Цикл
		
		ServiceProvider = "";
		Если ServiceProvider <> 0 Тогда 
			
			ServiceProvider = СокрЛП(rs.Fields(ColumnServiceProvider - 1).Value);
			
			Если Не ЗначениеЗаполнено(ServiceProvider) Тогда 
				Сообщить("In line " + НомерСтроки + "  Service provider!");
				БылиОшибки = Истина;
			КонецЕсли;
			
		КонецЕсли;
		
		Equipment = "";
		Если Equipment <> 0 Тогда 
			
			Equipment = СокрЛП(rs.Fields(ColumnEquipment - 1).Value);
			
			Если Не ЗначениеЗаполнено(Equipment) Тогда 
				Сообщить("In line " + НомерСтроки + "  Equipment!");
				БылиОшибки = Истина;
			КонецЕсли;
			
		КонецЕсли;
		
		Hours_a_day = СокрЛП(rs.Fields(ColumnHours_a_day - 1).Value);
		Milage  = СокрЛП(rs.Fields(ColumnMilage - 1).Value);
		Cost = СокрЛП(rs.Fields(ColumnCost - 1).Value);
		Date = СокрЛП(rs.Fields(ColumnDate - 1).Value);
		CostPerDay = СокрЛП(rs.Fields(ColumnCostPerDay - 1).Value);
		CostPerHour = СокрЛП(rs.Fields(ColumnCostPerHour - 1).Value);
		Currency = СокрЛП(rs.Fields(ColumnCurrency - 1).Value);
		Vehicle = СокрЛП(rs.Fields(ColumnVehicle - 1).Value);
		
		Если БылиОшибки Тогда 
			НомерСтроки = НомерСтроки + 1;
			rs.MoveNext();
			Продолжить;
		КонецЕсли;
		
		СтрокаТЗ = ТаблицаДанных.Добавить();
		СтрокаТЗ.ServiceProvider = ServiceProvider;
		СтрокаТЗ.Equipment = Equipment;
		СтрокаТЗ.Vehicle = Vehicle;
		СтрокаТЗ.Hours_a_day = Hours_a_day;
		СтрокаТЗ.Milage = Milage;
		СтрокаТЗ.Cost = Cost;
		СтрокаТЗ.Date = Дата(Date + " 00:00:00");
		СтрокаТЗ.CostPerHour = CostPerHour;
		СтрокаТЗ.CostPerDay = CostPerDay;
		СтрокаТЗ.Currency = Currency;
		
		НомерСтроки = НомерСтроки + 1;
		rs.MoveNext();
		
	КонецЦикла;
	
	rs.Close();
	Connection.Close();
	
КонецПроцедуры

&НаСервере
Процедура UpdateCatalogue() 
	
	УстановитьПривилегированныйРежим(Истина);
	
	ВыборкаДляОчистки = ТаблицаДанных.Выгрузить();
	ВыборкаДляОчистки.Свернуть("ServiceProvider, Equipment, Date");
	Для Каждого Элемент из ВыборкаДляОчистки Цикл
		
		Отбор = Новый Структура;
		Отбор.Вставить("Код", Элемент.ServiceProvider);
		Выборка = Справочники.ServiceProviders.Выбрать(,,Отбор);
		
		Пока Выборка.Следующий() Цикл
			
			Поставщик = Выборка.Ссылка;		
			Набор = РегистрыСведений.ServiceProvidersRentalTrucksCosts.СоздатьНаборЗаписей();
			Набор.Отбор.Период.Установить(Элемент.Date);
			Набор.Отбор.ServiceProvider.Установить(Поставщик);
			Набор.Отбор.Equipment.Установить(Справочники.Equipments.НайтиПоКоду(Элемент.Equipment));	
			Набор.Записать();
			
		КонецЦикла;
		
	КонецЦикла;
	
	Для Каждого Стр из ТаблицаДанных Цикл 	
		
		Отбор = Новый Структура;
		Отбор.Вставить("Код", Стр.ServiceProvider);
		ВыборкаПоставщик = Справочники.ServiceProviders.Выбрать(,,Отбор);
			Пока ВыборкаПоставщик.Следующий() Цикл
				
				Набор = РегистрыСведений.ServiceProvidersRentalTrucksCosts.СоздатьНаборЗаписей();
				Набор.Прочитать();
				НовЗапись = Набор.Добавить();
				НовЗапись.Период = Стр.Date;
				НовЗапись.ServiceProvider = ВыборкаПоставщик.Ссылка;
				НовЗапись.Equipment = Справочники.Equipments.НайтиПоКоду(Стр.Equipment);
				НовЗапись.Transport = Справочники.Transport.НайтиПоКоду(Стр.Vehicle);
				
				НовЗапись.Cost = Число(СтрЗаменить(Стр.Cost,",",""));
				НовЗапись.CostPerDay = Число(СтрЗаменить(Стр.CostPerDay,",",""));
				НовЗапись.CostPerHour = Число(СтрЗаменить(Стр.CostPerHour,",",""));
				НовЗапись.Hours_a_day = Число(СтрЗаменить(Стр.Hours_a_day,",",""));
				НовЗапись.Milage = Число(СтрЗаменить(Стр.Milage,",",""));
				НовЗапись.Currency = Справочники.Валюты.НайтиПоНаименованию(Стр.Currency); 
				Набор.Записать();
				
			КонецЦикла;	
	КонецЦикла;
		
КонецПроцедуры

СоответствиеСинонимовИимен = Новый Соответствие;
СоответствиеСинонимовИимен.Вставить("ColumnServiceProvider", "Service provider");
СоответствиеСинонимовИимен.Вставить("ColumnEquipment", "Equipment");
СоответствиеСинонимовИимен.Вставить("ColumnVehicle", "Vehicle");
СоответствиеСинонимовИимен.Вставить("ColumnHours_a_day", "Hours a day");
СоответствиеСинонимовИимен.Вставить("ColumnMilage", "Milage, km");
СоответствиеСинонимовИимен.Вставить("ColumnDate", "Date");
СоответствиеСинонимовИимен.Вставить("ColumnCost", "Cost");
СоответствиеСинонимовИимен.Вставить("ColumnCostPerHour", "Cost per hour");
СоответствиеСинонимовИимен.Вставить("ColumnCostPerDay", "Cost per day");
СоответствиеСинонимовИимен.Вставить("ColumnCurrency", "Currency");

