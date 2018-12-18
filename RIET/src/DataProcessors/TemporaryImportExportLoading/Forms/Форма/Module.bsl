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
			sqlString = "select top 1 * from [" + Sheet + "]";
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
	
	Если НЕ ЗначениеЗаполнено(Объект.ProcessLevel) Тогда
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Need to select Process level!",
			, "Объект", "ProcessLevel");
			Возврат;
		
	КонецЕсли;

	Если НЕ ЗначениеЗаполнено(Объект.TypeOfTransaction) Тогда
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Need to select Type Of Transaction!",
			, "Объект", "TypeOfTransaction");
			Возврат;
		
	КонецЕсли;

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
	ЗаполнитьTemporaryImportExport(Отказ);
	
	Если Отказ Тогда
		Предупреждение("No data was loaded due to errors.
			|See them on the right pane.", 60);
	Иначе
		Предупреждение("File was successfully loaded.", 60);	
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Функция ВсеПоляУказаны()
	
	ВсеПоляУказаны = Истина;
	      		
	Если ImportInvoice = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Need to specify the сolumn 'Import Invoice #'!");
		ВсеПоляУказаны = Ложь;
	КонецЕсли;
	
	Если PartNo = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Need to specify the сolumn 'Part #'!");
		ВсеПоляУказаны = Ложь;
	КонецЕсли;
	
	Если AC = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Need to specify the сolumn 'AC'!");
		ВсеПоляУказаны = Ложь;
	КонецЕсли;
	
	Если AU = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Need to specify the сolumn 'AU'!");
		ВсеПоляУказаны = Ложь;
	КонецЕсли;
	
	Если CCAJobRef = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Need to specify the сolumn 'CCA job ref.'!");
		ВсеПоляУказаны = Ложь;
	КонецЕсли;
	
	Если CountryOfOrigin = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Need to specify the сolumn 'Country of Origin'!");
		ВсеПоляУказаны = Ложь;
	КонецЕсли;
	
	Если Currency = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Need to specify the сolumn 'Currency'!");
		ВсеПоляУказаны = Ложь;
	КонецЕсли;
	
	Если CustomsFileNo = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Need to specify the сolumn 'Customs File No #'!");
		ВсеПоляУказаны = Ложь;
	КонецЕсли;
	
	Если CustomsRegime = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Need to specify the сolumn 'Customs Regime'!");
		ВсеПоляУказаны = Ложь;
	КонецЕсли;
	
	Если Currency = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Need to specify the сolumn 'Currency'!");
		ВсеПоляУказаны = Ложь;
	КонецЕсли;
	
	Если Description = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Need to specify the сolumn 'Description'!");
		ВсеПоляУказаны = Ложь;
	КонецЕсли;
	
	Если ERPTreatment = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Need to specify the сolumn 'ERP Treatment'!");
		ВсеПоляУказаны = Ложь;
	КонецЕсли;
	
	Если HTCCode = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Need to specify the сolumn 'HTC Code'!");
		ВсеПоляУказаны = Ложь;
	КонецЕсли;
	
	Если NetWeight = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Need to specify the сolumn 'Net Weight #'!");
		ВсеПоляУказаны = Ложь;
	КонецЕсли;
	
	Если ParentCompany = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Need to specify the сolumn 'Parent Company #'!");
		ВсеПоляУказаны = Ложь;
	КонецЕсли;
	
	Если PO = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Need to specify the сolumn 'PO'!");
		ВсеПоляУказаны = Ложь;
	КонецЕсли;
	
	Если POLine = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Need to specify the сolumn 'PO Line. #'!");
		ВсеПоляУказаны = Ложь;
	КонецЕсли;
	
	Если Price = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Need to specify the сolumn 'Price'!");
		ВсеПоляУказаны = Ложь;
	КонецЕсли;
	
	Если PSA = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Need to specify the сolumn 'PSA'!");
		ВсеПоляУказаны = Ложь;
	КонецЕсли;
	
	Если QTY = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Need to specify the сolumn 'QTY'!");
		ВсеПоляУказаны = Ложь;
	КонецЕсли;
	
	Если QtyUOM = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Need to specify the сolumn 'Qty UOM'!");
		ВсеПоляУказаны = Ложь;
	КонецЕсли;
	
	Если Responsible = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Need to specify the сolumn 'Responsible'!");
		ВсеПоляУказаны = Ложь;
	КонецЕсли;
	
	Если SerialNo = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Need to specify the сolumn 'Serial #'!");
		ВсеПоляУказаны = Ложь;
	КонецЕсли;
	
	Если ShipperName = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Need to specify the сolumn 'Shipper Name'!");
		ВсеПоляУказаны = Ложь;
	КонецЕсли;

	Если TotalPrice = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Need to specify the сolumn 'Total Price'!");
		ВсеПоляУказаны = Ложь;
	КонецЕсли;

	Если DateOfClearance = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Need to specify the сolumn 'Date of clearance'!");
		ВсеПоляУказаны = Ложь;
	КонецЕсли;

	Если NetWeightUOM = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Need to specify the сolumn 'Net weight UOM'!");
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
	
	ТаблицаTemporaryItems.Очистить();
	
	//запоняем таб.документ пока не кончаться строки
	Пока ?(АвтоОпределениеКонца, rs.EOF = 0 И ЗначениеЗаполнено(rs.Fields(0).Value), НомерТекущейСтроки <= LastRowOfData) Цикл
		
		СтрокаТЗ = ТаблицаTemporaryItems.Добавить();
		
		Для Каждого КлючИЗначение из СоответствиеСинонимовИимен Цикл 
			Если ТипЗнч(СтрокаТЗ[КлючИЗначение.Ключ]) = Тип("Дата") Тогда 
				СтрокаТЗ[КлючИЗначение.Ключ] = ПолучитьДатуИзСтроки(СокрЛП(rs.Fields(ЭтотОбъект[КлючИЗначение.Ключ] - 1).Value));
			иначе
				СтрокаТЗ[КлючИЗначение.Ключ] = СокрЛП(rs.Fields(ЭтотОбъект[КлючИЗначение.Ключ] - 1).Value);
			КонецЕсли;
		КонецЦикла;
		
		Если ПустаяСтрока(СтрокаТЗ.ExpiryDate) Тогда  
			СтрокаТЗ.ExpiryDate = ПолучитьДатуИзСтроки(СокрЛП(rs.Fields(ExpiryDate - 1).Value));
		КонецЕсли;

		Если ПустаяСтрока(СтрокаТЗ.DateOfClearance) Тогда 
			СтрокаТЗ.DateOfClearance = ПолучитьДатуИзСтроки(СокрЛП(rs.Fields(DateOfClearance - 1).Value));
		КонецЕсли;

		rs.MoveNext();
		НомерТекущейСтроки = НомерТекущейСтроки + 1;
		
	КонецЦикла;
	
	rs.Close();
	Connection.Close();
	
КонецПроцедуры

&НаКлиенте
Функция ПолучитьДатуИзСтроки(Знач ДатаСтрока) Экспорт
	   	
	ДатаСтрока = СокрЛП(ДатаСтрока);
	
	ПозицияЗапятой = СтрНайти(ДатаСтрока, ".");
	
	Если ПозицияЗапятой = 0 тогда
	   ПозицияЗапятой = СтрНайти(ДатаСтрока, "/");
   	КонецЕсли;
   
	ДеньСтрока = Лев(ДатаСтрока, ПозицияЗапятой - 1);	
	Попытка
		День = Число(ДеньСтрока);
	Исключение
		Возврат Неопределено;
	КонецПопытки;
	
	ОставшаясяСтрока = СокрЛ(Сред(ДатаСтрока, ПозицияЗапятой+1));
	
	МесяцСтрока = Лев(ОставшаясяСтрока, ПозицияЗапятой - 1);	
	Попытка
		Месяц = Число(МесяцСтрока);
	Исключение
		Возврат Неопределено;
	КонецПопытки;

	ОставшаясяСтрока = СокрЛ(Сред(ОставшаясяСтрока, ПозицияЗапятой+1));
	
	ГодСтрока = Лев(ОставшаясяСтрока, 4);
	Попытка
		Год = Число(ГодСтрока);
	Исключение
		Возврат Неопределено;
	КонецПопытки;
	
	Если СтрДлина(Месяц) = 1 тогда
		Месяц = "0"+Месяц;
	КонецЕсли;
	Если СтрДлина(День) = 1 тогда
		День = "0"+День;
	КонецЕсли;
	
	ИтоговаяДата = Дата(Год, Месяц, День);
	
	Возврат ИтоговаяДата;
			
КонецФункции

&НаКлиенте
Процедура ЗаполнитьТаблицуДанныхИзФайлаXLS_Update(Отказ, ПолноеИмяXLSФайла)
	
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
	
	ТаблицаTemporaryItems.Очистить();
	
	//запоняем таб.документ пока не кончаться строки
	Пока ?(АвтоОпределениеКонца, rs.EOF = 0 И ЗначениеЗаполнено(rs.Fields(0).Value), НомерТекущейСтроки <= LastRowOfData) Цикл
		
		СтрокаТЗ = ТаблицаTemporaryItems.Добавить();
		
		СтрокаТЗ.CustomsFileNo = СокрЛП(rs.Fields(CustomsFileNo - 1).Value);
		СтрокаТЗ.ExpiryDate = ПолучитьДатуИзСтроки(СокрЛП(rs.Fields(ExpiryDate - 1).Value));
		
		rs.MoveNext();
		НомерТекущейСтроки = НомерТекущейСтроки + 1;
		
	КонецЦикла;
	
	rs.Close();
	Connection.Close();
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьTemporaryImportExport(Отказ) 
	
	ТЗTemporaryItems = ТаблицаTemporaryItems.Выгрузить();
	Для Каждого СтрокаТаб из ТЗTemporaryItems Цикл
		СтрокаТаб.CustomsFileNo = СокрЛП(СтрокаТаб.CustomsFileNo);	
	КонецЦикла;
	 	
	МассивCustomsFileNo = РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ТЗTemporaryItems, "CustomsFileNo");
	СтруктураОтбора = Новый Структура("CustomsFileNo");

	ТаблицаTemporary = ПолучитьTemporaryImpExpTransactions(МассивCustomsFileNo);
	          		
	Для Каждого CustomsFileNum из МассивCustomsFileNo Цикл 
		
		Отказ = Ложь;
		НачатьТранзакцию(РежимУправленияБлокировкойДанных.Управляемый);

		СтруктураОтбора.CustomsFileNo = CustomsFileNum;
		ТЗCustomsFileNo = ТЗTemporaryItems.Скопировать(СтруктураОтбора);
		
		СтрокаТаб = ТЗCustomsFileNo[0];
		
		НайденнаяСтрока = ТаблицаTemporary.Найти(CustomsFileNum, "CustomsFileNo");
		       		
		Если НайденнаяСтрока <> Неопределено Тогда
			
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Transaction with customs file no.: '" + CustomsFileNum + "' already exists!",,,,Отказ);
			Продолжить;
			
		КонецЕсли;
		
		ТекОбъект = Документы.TemporaryImpExpTransactions.СоздатьДокумент();

		РГСофтКлиентСервер.УстановитьЗначение(ТекОбъект.CustomsFileNo, CustomsFileNum);
		РГСофтКлиентСервер.УстановитьЗначение(ТекОбъект.ProcessLevel, Объект.ProcessLevel);
		РГСофтКлиентСервер.УстановитьЗначение(ТекОбъект.TypeOfTransaction, Объект.TypeOfTransaction);
		РГСофтКлиентСервер.УстановитьЗначение(ТекОбъект.Дата, СтрокаТаб.DateOfClearance);
		
		РГСофтКлиентСервер.УстановитьЗначение(ТекОбъект.CustomsRegime, Справочники.CustomsRegimes.НайтиПоКоду(СокрЛП(СтрокаТаб.CustomsRegime)));
		РГСофтКлиентСервер.УстановитьЗначение(ТекОбъект.ExpiryDate, СтрокаТаб.ExpiryDate);
		РГСофтКлиентСервер.УстановитьЗначение(ТекОбъект.NewResponsible, Справочники.Пользователи.НайтиПоКоду(СокрЛП(СтрокаТаб.Responsible)));
		РГСофтКлиентСервер.УстановитьЗначение(ТекОбъект.CCAJobReference, СокрЛП(СтрокаТаб.CCAJobRef));
		РГСофтКлиентСервер.УстановитьЗначение(ТекОбъект.ShipperName, СокрЛП(СтрокаТаб.ShipperName));
		
		Для Каждого СтрокаТЗ из ТЗCustomsFileNo Цикл 
			
			Item = Справочники.СтрокиИнвойса.СоздатьЭлемент();
			Item.PermanentTemporary = Перечисления.PermanentTemporary.Temporary;
			Item.КодПоИнвойсу = стрзаменить(СтрокаТЗ.PartNo, символы.нпп, "");
			Item.СерийныйНомер = стрзаменить(СтрокаТЗ.SerialNo, символы.нпп, "");
			
			Item.ImportReference = СокрЛП(СтрокаТЗ.ImportInvoice);  
			Item.НаименованиеТовара = СокрЛП(СтрокаТЗ.Description);
			
			Item.NetWeight = СтрокаТЗ.NetWeight;
			Item.WeightUOM = Справочники.UOMs.НайтиПоКоду(СокрЛП(СтрокаТЗ.NetWeightUOM));
			
			Item.НомерВходящейДекларации = CustomsFileNo;
			Item.СтранаПроисхождения = СокрЛП(СтрокаТЗ.CountryOfOrigin);
			Item.НомерЗаявкиНаЗакупку = СокрЛП(СтрокаТЗ.PO);

			Item.Количество = СтрокаТЗ.Qty;
			Item.ЕдиницаИзмерения = Справочники.UOMs.НайтиПоКоду(СокрЛП(СтрокаТЗ.QtyUOM));
			Item.Цена = СтрокаТЗ.Price;
			Item.Сумма = СтрокаТЗ.TotalPrice;
			Item.Currency = Справочники.Валюты.НайтиПоНаименованию(СокрЛП(СтрокаТЗ.Currency)); 			
			
			Item.SoldTo = Справочники.SoldTo.НайтиПоКоду(СокрЛП(СтрокаТЗ.ParentCompany));
			
			КостЦентр = стрзаменить(СокрЛП(СтрокаТЗ.AU), символы.нпп, "");
			Пока СтрДлина(КостЦентр) < 7 Цикл
				КостЦентр = "0" + КостЦентр;
			КонецЦикла;
			Item.КостЦентр = Справочники.КостЦентры.НайтиПоКоду(КостЦентр);
			Если Не ЗначениеЗаполнено(Item.КостЦентр) Тогда 
				Сообщить("Не удалось найти AU "+КостЦентр);
			КонецЕсли;
			
			Item.Активити = СокрЛП(СтрокаТЗ.AC);
			
			Item.МеждународныйКодТНВЭД = СокрЛП(СтрокаТЗ.HTCCode);
			
			Если СокрЛП(СтрокаТЗ.ERPTreatment) = "Expense" Тогда
				Item.Классификатор = Перечисления.ТипыЗаказа.E;
			иначеЕсли СокрЛП(СтрокаТЗ.ERPTreatment) = "Inventory" Тогда
				Item.Классификатор = Перечисления.ТипыЗаказа.I;
			иначеЕсли СокрЛП(СтрокаТЗ.ERPTreatment) = "Assets" Тогда
				Item.Классификатор = Перечисления.ТипыЗаказа.A;
			иначеЕсли СокрЛП(СтрокаТЗ.ERPTreatment) = "Recharge" Тогда
				Item.Классификатор = Перечисления.ТипыЗаказа.R;
			иначеЕсли СокрЛП(СтрокаТЗ.ERPTreatment) = "Internal recharge" Тогда
				Item.Классификатор = Перечисления.ТипыЗаказа.X;
			иначеЕсли СокрЛП(СтрокаТЗ.ERPTreatment) = "Direct Sale" Тогда
				Item.Классификатор = Перечисления.ТипыЗаказа.S;
			иначеЕсли СокрЛП(СтрокаТЗ.ERPTreatment) = "Asset (NFTE) Under Construction" Тогда
				Item.Классификатор = Перечисления.ТипыЗаказа.U;
			иначеЕсли СокрЛП(СтрокаТЗ.ERPTreatment) = "Asset (FTE) Under Construction" Тогда
				Item.Классификатор = Перечисления.ТипыЗаказа.V;
			иначеЕсли СокрЛП(СтрокаТЗ.ERPTreatment) = "RAN" Тогда
				Item.Классификатор = Перечисления.ТипыЗаказа.RAN;
			иначеЕсли СокрЛП(СтрокаТЗ.ERPTreatment) = "LOAN" Тогда
				Item.Классификатор = Перечисления.ТипыЗаказа.LOAN;
			иначеЕсли СокрЛП(СтрокаТЗ.ERPTreatment) = "FMT" Тогда
				Item.Классификатор = Перечисления.ТипыЗаказа.FMT;
			иначеЕсли СокрЛП(СтрокаТЗ.ERPTreatment) = "FAT" Тогда
				Item.Классификатор = Перечисления.ТипыЗаказа.FAT;
			иначеЕсли СокрЛП(СтрокаТЗ.ERPTreatment) = "Short shipment" Тогда
				Item.Классификатор = Перечисления.ТипыЗаказа.SS;
			КонецЕсли;
			
			Item.Final = Истина;
			Попытка
				Item.Записать();
			Исключение
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"Failed to save item with part no.'" + Item.КодПоИнвойсу + 
					"' in transaction with customs file no.'" + CustomsFileNum + 
					"'. See errors above.",,,, Отказ);
			КонецПопытки;

			СтрокаItems = ТекОбъект.Items.Добавить();
			СтрокаItems.Item = Item.Ссылка;
			
		КонецЦикла;
		         			  		
		Попытка
			ТекОбъект.Записать(РежимЗаписиДокумента.Проведение);
		Исключение
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Failed to save transaction with customs file no.'" + CustomsFileNum + "'. See errors above.",,,, Отказ);
		КонецПопытки;
		
		Если Отказ Тогда
			ОтменитьТранзакцию();
		Иначе
			ЗафиксироватьТранзакцию();
		КонецЕсли;
		
	КонецЦикла;
	         	
КонецПроцедуры

&НаСервере
Функция ПолучитьTemporaryImpExpTransactions(МассивCustomsFileNo)
	
	// Выполним пакет запросов
	УстановитьПривилегированныйРежим(Истина);
	
	// Сформируем пакет запросов
	Запрос = Новый Запрос;
	
	Запрос.УстановитьПараметр("МассивCustomsFileNo", МассивCustomsFileNo);
	Запрос.УстановитьПараметр("ProcessLevel", Объект.ProcessLevel);
	
	Запрос.Текст = "ВЫБРАТЬ
	               |	TemporaryImpExpTransactionsItems.Ссылка,
	               |	СУММА(TemporaryImpExpTransactionsItems.Item.Количество) КАК Qty,
	               |	СУММА(ЕСТЬNULL(QtyOfItemsInTemporaryImpExpОстатки.QtyОстаток, 0)) КАК QtyОстаток,
	               |	TemporaryImpExpTransactionsItems.Ссылка.CustomsFileNo
	               |ИЗ
	               |	Документ.TemporaryImpExpTransactions.Items КАК TemporaryImpExpTransactionsItems
	               |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.QtyOfItemsInTemporaryImpExp.Остатки КАК QtyOfItemsInTemporaryImpExpОстатки
	               |		ПО TemporaryImpExpTransactionsItems.Item = QtyOfItemsInTemporaryImpExpОстатки.Item
	               |ГДЕ
	               |	TemporaryImpExpTransactionsItems.Ссылка.ProcessLevel = &ProcessLevel
	               |	И TemporaryImpExpTransactionsItems.Ссылка.CustomsFileNo В(&МассивCustomsFileNo)
	               |	И НЕ TemporaryImpExpTransactionsItems.Ссылка.ПометкаУдаления
	               |	И НЕ TemporaryImpExpTransactionsItems.Item.ПометкаУдаления
	               |
	               |СГРУППИРОВАТЬ ПО
	               |	TemporaryImpExpTransactionsItems.Ссылка,
	               |	TemporaryImpExpTransactionsItems.Ссылка.CustomsFileNo
	               |
	               |ОБЪЕДИНИТЬ ВСЕ
	               |
	               |ВЫБРАТЬ
	               |	CustomsFilesLightItems.Ссылка,
	               |	СУММА(CustomsFilesLightItems.Item.Количество),
	               |	СУММА(ЕСТЬNULL(QtyOfItemsInTemporaryImpExpОстатки.QtyОстаток, 0)),
	               |	CustomsFilesLightItems.Ссылка.Номер
	               |ИЗ
	               |	Документ.CustomsFilesLight.Items КАК CustomsFilesLightItems
	               |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.QtyOfItemsInTemporaryImpExp.Остатки(, ) КАК QtyOfItemsInTemporaryImpExpОстатки
	               |		ПО CustomsFilesLightItems.Item = QtyOfItemsInTemporaryImpExpОстатки.Item
	               |ГДЕ
	               |	CustomsFilesLightItems.Ссылка.ProcessLevel = &ProcessLevel
	               |	И CustomsFilesLightItems.Ссылка.Номер В(&МассивCustomsFileNo)
	               |	И НЕ CustomsFilesLightItems.Ссылка.ПометкаУдаления
	               |	И НЕ CustomsFilesLightItems.Item.ПометкаУдаления
	               |
	               |СГРУППИРОВАТЬ ПО
	               |	CustomsFilesLightItems.Ссылка,
	               |	CustomsFilesLightItems.Ссылка.Номер";
		   		
	Возврат Запрос.Выполнить().Выгрузить();
	
КонецФункции

////////////////////////////
// UPDATE

&НаКлиенте
Процедура UpdateExpiryDate(Команда)
	
	UpdateExpiryDateНаКлиенте();
	
КонецПроцедуры

&НаКлиенте
Процедура UpdateExpiryDateНаКлиенте()
	
	Если НЕ ЗначениеЗаполнено(Объект.ProcessLevel) Тогда
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Need to select Process level!",
			, "Объект", "ProcessLevel");
			Возврат;
		
	КонецЕсли;
	
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
	
	Если CustomsFileNo = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Need to specify the сolumn 'Customs File No #'!");
		ВсеПоляУказаны = Ложь;
	КонецЕсли;
	
	Если ExpiryDate = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Need to specify the сolumn 'Expiry Date'!");
		ВсеПоляУказаны = Ложь;
	КонецЕсли;
		
	Отказ = Ложь;
	
	ЗаполнитьТаблицуДанныхИзФайлаXLS_Update(Отказ, FullPath);
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
		
	Состояние("Updating data...");
	ЗаполнитьTemporaryImportExport_Update(Отказ);
	
	Если Не Отказ Тогда
		Сообщить("File was loaded.", 60);	
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьTemporaryImportExport_Update(Отказ) 
	
	ТЗTemporaryItems = ТаблицаTemporaryItems.Выгрузить();
	Для Каждого СтрокаТаб из ТЗTemporaryItems Цикл
		СтрокаТаб.CustomsFileNo = СокрЛП(СтрокаТаб.CustomsFileNo);	
	КонецЦикла;
	 	
	МассивCustomsFileNo = РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ТЗTemporaryItems, "CustomsFileNo");
	СтруктураОтбора = Новый Структура("CustomsFileNo");

	ТаблицаTemporary = ПолучитьTemporaryImpExpTransactions(МассивCustomsFileNo);
	                    	
	Для Каждого CustomsFileNum из МассивCustomsFileNo Цикл 
		
		Отказ = Ложь;
		НачатьТранзакцию(РежимУправленияБлокировкойДанных.Управляемый);
		
		СтруктураОтбора.CustomsFileNo = CustomsFileNum;
		ТЗCustomsFileNo = ТЗTemporaryItems.Скопировать(СтруктураОтбора);
		   		
		НайденнаяСтрока = ТаблицаTemporary.Найти(CustomsFileNum, "CustomsFileNo");
		
		Если НайденнаяСтрока = Неопределено Тогда
			
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Failed to find transaction with customs file no.: '" + CustomsFileNum + "'!",,,,Отказ);
						
		иначе
			
			Если НайденнаяСтрока.QtyОстаток = НайденнаяСтрока.Qty Тогда 
				
				ТекОбъект = НайденнаяСтрока.Ссылка.ПолучитьОбъект();
				РГСофтКлиентСервер.УстановитьЗначение(ТекОбъект.ExpiryDate, СтрокаТаб.ExpiryDate);
				
				Если ТекОбъект.Модифицированность() Тогда 
					
					Попытка
						ТекОбъект.Записать(?(ТекОбъект.Проведен, РежимЗаписиДокумента.Проведение, РежимЗаписиДокумента.Запись));
					Исключение
						ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
						"Failed to update transaction with customs file no.'" + CustomsFileNum + "'. See errors above.",,,, Отказ);
					КонецПопытки;
					
				КонецЕсли;
			
			иначе
				
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"Some items of transaction with customs file no.'" + CustomsFileNum + "' are not temporary.",,,, Отказ);
										
			КонецЕсли;	
			
		КонецЕсли;
		
		Если Отказ Тогда
			ОтменитьТранзакцию();
		Иначе
			Сообщить("Transaction with customs file no.'" + CustomsFileNum + "' was successfully updated.");
			ЗафиксироватьТранзакцию();
		КонецЕсли;

	КонецЦикла;
	  	
КонецПроцедуры


СоответствиеСинонимовИимен = Новый Соответствие;
СоответствиеСинонимовИимен.Вставить("ImportInvoice", "Import Invoice #");
СоответствиеСинонимовИимен.Вставить("PartNo", "Part #");
СоответствиеСинонимовИимен.Вставить("SerialNo", "Serial #");
СоответствиеСинонимовИимен.Вставить("Description", "Description");
СоответствиеСинонимовИимен.Вставить("CustomsRegime", "Customs Regime");
СоответствиеСинонимовИимен.Вставить("CustomsFileNo", "Customs File No #");
СоответствиеСинонимовИимен.Вставить("ExpiryDate", "Expiry Date");
СоответствиеСинонимовИимен.Вставить("DateOfClearance", "Date of clearance");
СоответствиеСинонимовИимен.Вставить("Responsible", "Responsible");
СоответствиеСинонимовИимен.Вставить("CCAJobRef", "CCA job ref.");
СоответствиеСинонимовИимен.Вставить("ShipperName", "Shipper Name");
СоответствиеСинонимовИимен.Вставить("NetWeight", "Net Weight #");
СоответствиеСинонимовИимен.Вставить("PO", "PO #");
СоответствиеСинонимовИимен.Вставить("POLine", "PO Line. #");
СоответствиеСинонимовИимен.Вставить("ParentCompany", "Parent Company #");
СоответствиеСинонимовИимен.Вставить("ERPTreatment", "ERP treatment");
СоответствиеСинонимовИимен.Вставить("AU", "AU");
СоответствиеСинонимовИимен.Вставить("AC", "AC");
СоответствиеСинонимовИимен.Вставить("CountryOfOrigin", "Country of Origin");
СоответствиеСинонимовИимен.Вставить("HTCCode", "HTC Code");
СоответствиеСинонимовИимен.Вставить("QTY", "QTY");
СоответствиеСинонимовИимен.Вставить("QtyUOM", "Qty UOM");
СоответствиеСинонимовИимен.Вставить("Price", "Price");
СоответствиеСинонимовИимен.Вставить("TotalPrice", "Total Price");
СоответствиеСинонимовИимен.Вставить("Currency", "Currency");
СоответствиеСинонимовИимен.Вставить("PSA", "PSA");
СоответствиеСинонимовИимен.Вставить("NetWeightUOM", "Net Weight UOM");

