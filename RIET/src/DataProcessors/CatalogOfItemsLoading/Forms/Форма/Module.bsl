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
	    		
КонецПроцедуры

&НаКлиенте
Функция ВсеПоляУказаны()
	
	ВсеПоляУказаны = Истина;
	      		
	Если ColumnPartNumber = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Need to specify the сolumn 'Part number'!");
		ВсеПоляУказаны = Ложь;
	КонецЕсли;
	
	//Если ColumnDescriptionRus = 0 Тогда
	//	ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
	//		"Need to specify the сolumn 'Description Rus'!");
	//	ВсеПоляУказаны = Ложь;
	//КонецЕсли;
	
	Если ColumnDescriptionEng = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Need to specify the сolumn 'Description Eng'!");
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
		
		PartNumber = СокрЛП(rs.Fields(ColumnPartNumber - 1).Value);
		
		Если Не ЗначениеЗаполнено(PartNumber) Тогда 
			Сообщить("In line " + НомерСтроки + " Part number is empty!");
			БылиОшибки = Истина;
		КонецЕсли;
		
		DescriptionRus = "";
		Если ColumnDescriptionRus <> 0 Тогда 
			
			DescriptionRus = СокрЛП(rs.Fields(ColumnDescriptionRus - 1).Value);
			
			Если Не ЗначениеЗаполнено(DescriptionRus) Тогда 
				Сообщить("In line " + НомерСтроки + " Description Rus is empty!");
				БылиОшибки = Истина;
			КонецЕсли;
			
		КонецЕсли;

		DescriptionEng = СокрЛП(rs.Fields(ColumnDescriptionEng - 1).Value);
		
		Если Не ЗначениеЗаполнено(DescriptionEng) Тогда 
			Сообщить("In line " + НомерСтроки + " Description Eng is empty!");
			БылиОшибки = Истина;
		КонецЕсли;

		Если БылиОшибки Тогда 
			НомерСтроки = НомерСтроки + 1;
			rs.MoveNext();
			Продолжить;
		КонецЕсли;

		СтрокаТЗ = ТаблицаДанных.Добавить();
		СтрокаТЗ.PartNumber = PartNumber;
		СтрокаТЗ.DescriptionEng = DescriptionEng;
		СтрокаТЗ.DescriptionRus = DescriptionRus;
		
		НомерСтроки = НомерСтроки + 1;
		rs.MoveNext();
		
	КонецЦикла;
	
	rs.Close();
	Connection.Close();
	
КонецПроцедуры

&НаСервере
Процедура UpdateCatalogue() 
	
	ЕстьОшибки = Ложь;
	УстановитьПривилегированныйРежим(Истина);
	
	Для Каждого Стр из ТаблицаДанных Цикл 
		
		Catalog = Справочники.Catalog.НайтиПоКоду(Стр.PartNumber);
		
		Если ЗначениеЗаполнено(Catalog) Тогда 
			Продолжить;
		КонецЕсли;
		
		НовыйCatalog = Справочники.Catalog.СоздатьЭлемент();
		
		НовыйCatalog.Код = Стр.PartNumber;
		НовыйCatalog.DescriptionEng = Стр.DescriptionEng;
		НовыйCatalog.DescriptionRus = Стр.DescriptionRus;			
		
		Попытка
			НовыйCatalog.Записать();
		Исключение
			Сообщить("Failed to save part number <" + Стр.PartNumber + ">:" 
			+ ОписаниеОшибки());
			ЕстьОшибки = Истина;
		КонецПопытки;
		
	КонецЦикла;	
	
	Если ЕстьОшибки Тогда
		Сообщить("File was loaded with errors.");
	Иначе
		Сообщить("File was successfully loaded.");	
	КонецЕсли;
	
КонецПроцедуры

СоответствиеСинонимовИимен = Новый Соответствие;
СоответствиеСинонимовИимен.Вставить("ColumnPartNumber", "Part number");
СоответствиеСинонимовИимен.Вставить("ColumnDescriptionEng", "Description Eng");
СоответствиеСинонимовИимен.Вставить("ColumnDescriptionRus", "Description Rus");


