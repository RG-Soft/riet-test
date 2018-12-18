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
	
	Если НЕ ЗначениеЗаполнено(Объект.ProjectMobilization) или НЕ ЗначениеЗаполнено(InternationalDomestic) Тогда
		Если НЕ ЗначениеЗаполнено(Объект.ProjectMobilization) тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Need to select Project Mobilization!",
			, "Объект", "ProjectMobilization");
		КонецЕсли;
		Если НЕ ЗначениеЗаполнено(InternationalDomestic) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Need to select International Domestic!",
			, "Объект", "InternationalDomestic");		
		КонецЕсли;
		Возврат
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
	
	//Сообщить("File was loaded.");
	
КонецПроцедуры

&НаКлиенте
Функция ВсеПоляУказаны()
	
	ВсеПоляУказаны = Истина;
	
	Если ColumnPartNumber = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"Need to specify the сolumn 'Part number'!");
		ВсеПоляУказаны = Ложь;
	КонецЕсли;
	
	Если ColumnDescription = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"Need to specify the сolumn 'Description'!");
		ВсеПоляУказаны = Ложь;
	КонецЕсли;
	
	//Если ColumnHazardClass = 0 Тогда
	//	ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
	//	"Need to specify the сolumn 'HazardClass'!");
	//	ВсеПоляУказаны = Ложь;
	//КонецЕсли;
	//
	//Если ColumnQty = 0 Тогда
	//	ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
	//	"Need to specify the сolumn 'Qty'!");
	//	ВсеПоляУказаны = Ложь;
	//КонецЕсли;
	//
	//Если ColumnItemValue = 0 Тогда
	//	ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
	//	"Need to specify the сolumn 'ItemValue'!");
	//	ВсеПоляУказаны = Ложь;
	//КонецЕсли;
	//
	//
	//Если ColumnGrossWeightKG = 0 Тогда
	//	ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
	//	"Need to specify the сolumn 'GrossWeightKG'!");
	//	ВсеПоляУказаны = Ложь;
	//КонецЕсли;
	//
	//Если ColumnRDD = 0 Тогда
	//	ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
	//	"Need to specify the сolumn 'RDD'!");
	//	ВсеПоляУказаны = Ложь;
	//КонецЕсли;
	//
	//
	//Если ColumnComments = 0 Тогда
	//	ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
	//	"Need to specify the сolumn 'Comments'!");
	//	ВсеПоляУказаны = Ложь;
	//КонецЕсли;
	//
	//Если ColumnPickUpWarehouse = 0 Тогда
	//	ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
	//	"Need to specify the сolumn 'PickUpWarehouse'!");
	//	ВсеПоляУказаны = Ложь;
	//КонецЕсли;
	//
	//
	//Если ColumnDeliverTo = 0 Тогда
	//	ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
	//	"Need to specify the сolumn 'DeliverTo'!");
	//	ВсеПоляУказаны = Ложь;
	//КонецЕсли;
	
	Если InternationalDomestic = ПредопределенноеЗначение("Перечисление.DomesticInternational.International")
		И ColumnSupplierAvailability = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"Need to specify the сolumn 'Supplier availability date'!");
		ВсеПоляУказаны = Ложь;
	КонецЕсли;
	
	Если InternationalDomestic = ПредопределенноеЗначение("Перечисление.DomesticInternational.Domestic")
		И ColumnReadyToShip = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"Need to specify the сolumn 'Ready to ship date'!");
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
		
		PartNumber = "";
		Если ColumnPartNumber <> 0 Тогда 
			
			PartNumber = СокрЛП(rs.Fields(ColumnPartNumber - 1).Value);
			
			Если Не ЗначениеЗаполнено(PartNumber) Тогда 
				Сообщить("In line " + НомерСтроки + "  Part number is empty!");
				БылиОшибки = Истина;
			КонецЕсли;
			
		КонецЕсли;
		
		Если ColumnDescription <> 0 Тогда
			Description = СокрЛП(rs.Fields(ColumnDescription - 1).Value);
		КонецЕсли;
		
		Если Не ЗначениеЗаполнено(Description) Тогда 
			Сообщить("In line " + НомерСтроки + " Description is empty!");
			БылиОшибки = Истина;
		КонецЕсли;
		
		HazardClass = "";
		Если ColumnHazardClass <> 0 Тогда
			HazardClass = СокрЛП(rs.Fields(ColumnHazardClass - 1).Value);
		КонецЕсли;
		
		Qty = "";
		Если ColumnQty <> 0 Тогда
			Qty = СокрЛП(rs.Fields(ColumnQty - 1).Value);
		КонецЕсли;
		
		ItemValue = "";
		Если ColumnItemValue <> 0 Тогда
			ItemValue = СокрЛП(rs.Fields(ColumnItemValue - 1).Value);
		КонецЕсли;
		
		GrossWeightKG = "";
		Если ColumnGrossWeightKG <> 0 Тогда
			GrossWeightKG = СокрЛП(rs.Fields(ColumnGrossWeightKG - 1).Value);
			Если НЕ ЗначениеЗаполнено(GrossWeightKG) Тогда
				GrossWeightKG = 0;
			Иначе
				GrossWeightKG = Число(GrossWeightKG);
			КонецЕсли;
		КонецЕсли;
		
		RDD = "";
		Если ColumnRDD <> 0 Тогда
			RDD = СокрЛП(rs.Fields(ColumnRDD - 1).Value);
		КонецЕсли;
		
		Comments = "";
		Если ColumnComments <> 0 Тогда
			Comments  = СокрЛП(rs.Fields(ColumnComments - 1).Value);
		КонецЕсли;
		
		PickUpWarehouse = "";
		
		DeliverTo = "";
		
		Если InternationalDomestic = ПредопределенноеЗначение("Перечисление.DomesticInternational.International") Тогда
			
			Если ColumnSupplierAvailability <> 0 Тогда
				SupplierAvailability = СокрЛП(rs.Fields(ColumnSupplierAvailability - 1).Value);
			КонецЕсли;
			
			Если ColumnPOD <> 0 Тогда
				POD = СокрЛП(rs.Fields(ColumnPOD - 1).Value);
			КонецЕсли;
			
			Если ColumnSupplier <> 0 Тогда
				Supplier = СокрЛП(rs.Fields(ColumnSupplier - 1).Value);
			КонецЕсли;
			
		КонецЕсли;
		
		Если InternationalDomestic = ПредопределенноеЗначение("Перечисление.DomesticInternational.Domestic") Тогда
			
			Если ColumnReadyToShip <> 0 Тогда
				ReadyToShip = СокрЛП(rs.Fields(ColumnReadyToShip - 1).Value);
			КонецЕсли;
			
			Если ColumnPickUpWarehouse <> 0 Тогда
				PickUpWarehouse = СокрЛП(rs.Fields(ColumnPickUpWarehouse - 1).Value);
			КонецЕсли;
			
			Если ColumnDeliverTo <> 0 Тогда
				DeliverTo = СокрЛП(rs.Fields(ColumnDeliverTo - 1).Value);
			КонецЕсли;
			
		КонецЕсли;

		Если БылиОшибки Тогда 
			НомерСтроки = НомерСтроки + 1;
			rs.MoveNext();
			Продолжить;
		КонецЕсли;
		
		СтрокаТЗ = ТаблицаДанных.Добавить();
		СтрокаТЗ.PartNumber = PartNumber;
		СтрокаТЗ.Description = Description;
		СтрокаТЗ.HazardClass = HazardClass;
		СтрокаТЗ.Qty = Qty;
		СтрокаТЗ.ItemValue = ItemValue;
		СтрокаТЗ.GrossWeightKG = GrossWeightKG;
		СтрокаТЗ.RDD = RDD;
		СтрокаТЗ.Comments = Comments;
		СтрокаТЗ.PickUpWarehouse = PickUpWarehouse;
		СтрокаТЗ.DeliverTo = DeliverTo;
		СтрокаТЗ.POD = POD;
		СтрокаТЗ.Supplier = Supplier;
		СтрокаТЗ.SupplierAvailability = SupplierAvailability;
		СтрокаТЗ.ReadyToShip = ReadyToShip;

		НомерСтроки = НомерСтроки + 1;
		rs.MoveNext();
		
	КонецЦикла;
	
	rs.Close();
	Connection.Close();
	
КонецПроцедуры

&НаСервере
Процедура UpdateCatalogue() 
	
	ТекстОшибок = "";
	УстановитьПривилегированныйРежим(Истина);
	
	Запрос = новый запрос;
	Запрос.УстановитьПараметр("Project", Объект.ProjectMobilization);
	Запрос.УстановитьПараметр("DomesticInternational", InternationalDomestic);
	
	Запрос.Текст = "ВЫБРАТЬ
	|	ProjectMobilizationManualItems.Ссылка,
	|	ProjectMobilizationManualItems.Наименование
	|ИЗ
	|	Справочник.ProjectMobilizationManualItems КАК ProjectMobilizationManualItems
	|ГДЕ
	|	ProjectMobilizationManualItems.Владелец = &Project
	|	И НЕ ProjectMobilizationManualItems.ПометкаУдаления
	|	И ProjectMobilizationManualItems.DomesticInternational = &DomesticInternational";
	
	Результат = запрос.Выполнить().Выгрузить();
	
	ТаблицаЗагрузки = ТаблицаДанных.Выгрузить();
	ТаблицаЗагрузки.Свернуть("PartNumber", "Qty");
	
	Для Каждого Строка из ТаблицаЗагрузки Цикл 		
		
		Отбор = Новый Структура;
		Отбор.Вставить("PartNumber", Строка.PartNumber);
		ТаблицаДанныхПоPartNumber = ТаблицаДанных.Выгрузить(Отбор);
		
		Если ТаблицаДанныхПоPartNumber.Количество()= 0 Тогда
			Продолжить
		КонецЕсли;
			
			Стр = ТаблицаДанныхПоPartNumber[0];  	
			Отбор = Новый Структура;
			Отбор.Вставить("Наименование",Стр.PartNumber);	
			Рез = Результат.Скопировать(Отбор);	
			Если Рез.Количество() = 0 тогда
				MobilizationItem = Справочники.ProjectMobilizationManualItems.СоздатьЭлемент();
				MobilizationItem.Владелец = Объект.ProjectMobilization;	
				MobilizationItem.DomesticInternational = InternationalDomestic;	
			Иначе
				MobilizationItem = Рез[0].Ссылка.ПолучитьОбъект();
			КонецЕсли;
			
			MobilizationItem.Наименование = Стр.PartNumber;
			MobilizationItem.ItemDescription = Стр.Description;
			Если Стр.HazardClass <> "" Тогда 
				MobilizationItem.HazardClass = Справочники.HazardClasses.НайтиПоКоду(Стр.HazardClass);
			Иначе
				MobilizationItem.HazardClass = Справочники.HazardClasses.NonHazardous;
			КонецЕсли;
			
			попытка
				MobilizationItem.Qty = Число(Стр.Qty);
			Исключение
				ТекстОшибок = ТекстОшибок + "
				|не удалось преобразовать Qty для Part number "+ Стр.PartNumber + ",
				|"+ ОписаниеОшибки();
			КонецПопытки;
			
			попытка
				MobilizationItem.ItemValue = Число(Стр.ItemValue);
			Исключение
				ТекстОшибок = ТекстОшибок + "
				|не удалось преобразовать Item Value для Part number "+ Стр.PartNumber + ",
				|"+ ОписаниеОшибки();
			КонецПопытки;

			попытка
				MobilizationItem.GrossWeightKG = Число(Стр.GrossWeightKG);
			Исключение
				ТекстОшибок = ТекстОшибок + "
				|не удалось преобразовать Gross Weight KG для Part number "+ Стр.PartNumber + ",
				|"+ ОписаниеОшибки();
			КонецПопытки;
			
			MobilizationItem.TotalValue = MobilizationItem.Qty * MobilizationItem.ItemValue;
			MobilizationItem.TotalGrossWeightKG = MobilizationItem.Qty * MobilizationItem.GrossWeightKG;
			попытка
				MobilizationItem.RDD = Дата(Стр.RDD + " 00:00:00");
			Исключение
				ТекстОшибок = ТекстОшибок + "
				|не удалось преобразовать RDD для Part number "+ Стр.PartNumber + ",
				|"+ ОписаниеОшибки();
			КонецПопытки;
		
			MobilizationItem.Comments = Стр.Comments;
			MobilizationItem.ModifiedBy = ПараметрыСеанса.ТекущийПользователь;
			MobilizationItem.ModificationDate = ТекущаяДата();
			
			Если InternationalDomestic = Перечисления.DomesticInternational.International Тогда
				
				попытка
					MobilizationItem.SupplierAvailability = Дата(Стр.SupplierAvailability + " 00:00:00");
				Исключение
					ТекстОшибок = ТекстОшибок + "
					|не удалось преобразовать Supplier availability date для Part number "+ Стр.PartNumber + ",
					|"+ ОписаниеОшибки();
				КонецПопытки;
				
				MobilizationItem.POD = Справочники.CountriesHUBs.НайтиПоКоду(Стр.POD);
				Если Не ЗначениеЗаполнено(MobilizationItem.POD) Тогда 
					ТекстОшибок = ТекстОшибок + "
					|не удалось найти POD для Part number "+ Стр.PartNumber + ",
					|"+ ОписаниеОшибки();
				КонецЕсли;

				MobilizationItem.Supplier = Стр.Supplier;
				
			Иначе
				
				MobilizationItem.SupplierAvailability = Неопределено;
				MobilizationItem.POD = Неопределено;
				MobilizationItem.Supplier = Неопределено;
				
			КонецЕсли;
			
			Если InternationalDomestic = Перечисления.DomesticInternational.Domestic Тогда
				
				попытка
					MobilizationItem.ReadyToShip = Дата(Стр.ReadyToShip + " 00:00:00");
				Исключение
					ТекстОшибок = ТекстОшибок + "
					|не удалось преобразовать Ready To Ship date для Part number "+ Стр.PartNumber + ",
					|"+ ОписаниеОшибки();
				КонецПопытки;
				
				MobilizationItem.PickUpWarehouse = Справочники.Warehouses.НайтиПоНаименованию(Стр.PickUpWarehouse);
				Если Не ЗначениеЗаполнено(MobilizationItem.PickUpWarehouse) Тогда 
					ТекстОшибок = ТекстОшибок + "
					|не удалось найти Pick Up Warehouse для Part number "+ Стр.PartNumber + ",
					|"+ ОписаниеОшибки();
				КонецЕсли;

				MobilizationItem.DeliverTo = Справочники.Warehouses.НайтиПоНаименованию(Стр.DeliverTo);
				Если Не ЗначениеЗаполнено(MobilizationItem.DeliverTo) Тогда 
					ТекстОшибок = ТекстОшибок + "
					|не удалось найти Deliver To для Part number "+ Стр.PartNumber + ",
					|"+ ОписаниеОшибки();
				КонецЕсли;
				
			Иначе
				
				MobilizationItem.PickUpWarehouse = Неопределено;
				MobilizationItem.DeliverTo = Неопределено;
				MobilizationItem.ReadyToShip = Неопределено;
				
			КонецЕсли;
			
			НачатьТранзакцию();
			
			Попытка		
				MobilizationItem.Записать();
			Исключение
				ТекстОшибок = ТекстОшибок + "
				|не удалось записать Item для Part number "+ Стр.PartNumber + ",
				|"+ ОписаниеОшибки();
				ОтменитьТранзакцию();
			КонецПопытки;
			
			ЗафиксироватьТранзакцию()
		
	КонецЦикла;
	
	Если ТекстОшибок = "" Тогда  
		Сообщить("File was successfully loaded.");	    
	Иначе
		Сообщить("File was loaded with errors:
		|" + ТекстОшибок);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура InternationalDomesticПриИзменении(Элемент)
	
	Элементы.ГруппаDomestic.Видимость = (InternationalDomestic = ПредопределенноеЗначение("Перечисление.DomesticInternational.Domestic"));
	Элементы.ГруппаInternational.Видимость = (InternationalDomestic = ПредопределенноеЗначение("Перечисление.DomesticInternational.International"));	
		
КонецПроцедуры

СоответствиеСинонимовИимен = Новый Соответствие;
СоответствиеСинонимовИимен.Вставить("ColumnPartNumber", "Part Number");
СоответствиеСинонимовИимен.Вставить("ColumnDescription", "Description");
СоответствиеСинонимовИимен.Вставить("ColumnHazardClass", "Hazard Class");
СоответствиеСинонимовИимен.Вставить("ColumnQty", "Qty");
СоответствиеСинонимовИимен.Вставить("ColumnItemValue", "Item value");
СоответствиеСинонимовИимен.Вставить("ColumnGrossWeightKG", "Gross weight, kg");
СоответствиеСинонимовИимен.Вставить("ColumnRDD", "RDD");
СоответствиеСинонимовИимен.Вставить("ColumnComments", "Comments");
СоответствиеСинонимовИимен.Вставить("ColumnPickUpWarehouse", "Pick up warehouse");
СоответствиеСинонимовИимен.Вставить("ColumnDeliverTo", "Deliver to");
СоответствиеСинонимовИимен.Вставить("ColumnReadyToShip", "Ready to ship");
СоответствиеСинонимовИимен.Вставить("ColumnPOD", "POD");
СоответствиеСинонимовИимен.Вставить("ColumnSupplierAvailability", "Supplier availability");
СоответствиеСинонимовИимен.Вставить("ColumnSupplier", "Supplier");




