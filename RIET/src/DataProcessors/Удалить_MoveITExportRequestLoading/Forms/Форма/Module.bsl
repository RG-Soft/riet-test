
//////////////////////////////////////////////////////////////////////////////////////
// СОБЫТИЯ ФОРМЫ

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ВыбратьФайл();
	
КонецПроцедуры


//////////////////////////////////////////////////////////////////////////////////////
// ВЫБОР ФАЙЛА

&НаКлиенте
Процедура FullPathНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ВыбратьФайл();
	
КонецПроцедуры

&НаКлиенте
Процедура ВыбратьФайл()
	
	ДиалогВыбораФайла = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	
	ДиалогВыбораФайла.Фильтр						= "Файлы xlsm (*.xlsm)|*.xlsm";
	ДиалогВыбораФайла.ПроверятьСуществованиеФайла	= Истина;
	
	Если ДиалогВыбораФайла.Выбрать() Тогда
		
		FullPath = ДиалогВыбораФайла.ПолноеИмяФайла;
				
	КонецЕсли;
		
КонецПроцедуры


//////////////////////////////////////////////////////////////////////////////////////
// ЗАГРУЗКА

&НаКлиенте
Процедура Load(Команда)
	
	Если НЕ ЗначениеЗаполнено(FullPath) Тогда
		
		ВыбратьФайл();
		
		Если НЕ ЗначениеЗаполнено(FullPath) Тогда
			
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Файл не выбран!",
				, "Объект", "FullPath");
				Возврат;
			
		КонецЕсли;
		
	КонецЕсли;
	
	ЗагрузитьДанныеИзФайла(FullPath);
	
КонецПроцедуры

&НаКлиенте
Процедура ЗагрузитьДанныеИзФайла(FullPath)
	
	Если НЕ РГСофтКлиентСервер.ФайлДоступенДляЗагрузки(FullPath) Тогда
		Возврат;
	КонецЕсли;
	
	Файл = Новый Файл(FullPath);
	РасширениеФайла = НРег(Файл.Расширение);	
	Если НЕ РасширениеФайла = ".xls" И НЕ РасширениеФайла = ".xlsx" И НЕ РасширениеФайла = ".xlsm" Тогда	
		Сообщить("Unknown file extension (." + РасширениеФайла + "). Only .xls or .xlsx or .xlsm files can be used!");
		Возврат;	
	КонецЕсли;
		
	ЗагрузитьДанныеИзПроверенногоФайла(FullPath);
		
КонецПроцедуры 

&НаКлиенте
Процедура ЗагрузитьДанныеИзПроверенногоФайла(FullPath)
	
	БылиКритическиеОшибки = Ложь;
	БылиНедочеты = Ложь;
	
	Состояние("Reading data from file...");
	ПрочитатьФайлВоВременныеТаблицы(БылиКритическиеОшибки, БылиНедочеты, FullPath);	
	Если БылиКритическиеОшибки Тогда
		ПредупредитьОКритическойОшибке();
		Возврат;
	КонецЕсли; 
		
	Состояние("Preparation of the read data...");
	ПодготовитьТекстовыеРеквизитыИТаблицы(БылиКритическиеОшибки, БылиНедочеты);
	Если БылиКритическиеОшибки Тогда
		ПредупредитьОКритическойОшибке();
		Возврат;
	КонецЕсли; 
	
	Состояние("Creating Export request, Items and Parcels...");
	
	// Подготовим переменные, необходимые для прикрепления файла к Export request
	Файл = Новый Файл(FullPath);
	УниверсальноеВремяИзменения = Файл.ПолучитьУниверсальноеВремяИзменения();
	АдресФайла = Неопределено;
	Попытка
		ПоместитьФайл(АдресФайла, FullPath,, Ложь, УникальныйИдентификатор);
	Исключение
		БылиКритическиеОшибки = Истина;
		Сообщить("Failed to prepare file for attachment!
			|" + ОписаниеОшибки());	
		ПредупредитьОКритическойОшибке();
		Возврат;
	КонецПопытки;
	
	ExportRequest = СоздатьОбъектыБазыИзВременныхТаблиц(БылиКритическиеОшибки, БылиНедочеты, FullPath, УниверсальноеВремяИзменения, АдресФайла);
	
	Если БылиКритическиеОшибки Тогда
		ПредупредитьОКритическойОшибке();
		Возврат;
	ИначеЕсли БылиНедочеты Тогда
		Предупреждение("There were errors!
			|See them on the right side of loading window.",
			60);
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ExportRequest) Тогда
		ОткрытьЗначение(ExportRequest);
	КонецЕсли;
	
КонецПроцедуры 

&НаКлиенте
Процедура ПредупредитьОКритическойОшибке()
	
	Предупреждение("Failed to load Export request!
		|See errors on the right side of loading window.",
		60);
	
КонецПроцедуры


// ЧТЕНИЕ ФАЙЛА ВО ВРЕМЕННЫЕ ТАБЛИЦЫ

// ДОДЕЛАТЬ
&НаКлиенте
Процедура ПрочитатьФайлВоВременныеТаблицы(БылиКритическиеОшибки, БылиНедочеты, FullPath)
	
	// Откроем Excel
	Состояние("Opening Excel...");
	Попытка
		Excel = Новый COMОбъект("Excel.Application");
	Исключение
		Сообщить("Failed to open Excel!
			|" + ОписаниеОшибки(), СтатусСообщения.ОченьВажное);
		БылиКритическиеОшибки = Истина;
		Возврат;
	КонецПопытки;
	
	// Откроем файл
	Состояние("Opening file with Excel...");
	Workbooks = Excel.Workbooks;
	Попытка
		Workbook = Workbooks.Open(FullPath, , Истина);
	Исключение
		Excel.Quit();
		Сообщить("Failed to open file with Excel!
			|" + ОписаниеОшибки(), СтатусСообщения.ОченьВажное);
		БылиКритическиеОшибки = Истина;
		Возврат;
	КонецПопытки;
	
	// Откроем нужный лист
	Состояние("Opening sheet...");
	Попытка
		WorkSheet = Workbook.Worksheets("Transport Booking Request");
	Исключение
		Excel.Quit();
		Сообщить("Failed to open sheet ""Transport Booking Request""!
			|" + ОписаниеОшибки(), СтатусСообщения.ОченьВажное);
		БылиКритическиеОшибки = Истина;
		Возврат;
	КонецПопытки;
	          	  
	
	// Section 1 Shipment information
	Состояние("Section 1 Shipment Information...");
	
	RequesterLDAPAlias = ВРег(СокрЛП(WorkSheet.Cells(7, 5).Text));
	
	//ReceiverLDAPAlias = ВРег(СокрЛП(WorkSheet.Cells(10 ,5).Text)); // Это поле скрыли
	
	RechargeCountry = СокрЛП(WorkSheet.Cells(12, 5).Text);
	
	Segment = СокрЛП(WorkSheet.Cells(13, 5).Text);
	
	BORG = СокрЛП(WorkSheet.Cells(14, 5).Text);
	
	AU = СокрЛП(WorkSheet.Cells(15, 5).Text);
	
	Activity = СокрЛП(WorkSheet.Cells(16, 5).Text);
	
	InvoiceToEntity = СокрЛП(WorkSheet.Cells(17, 5).Text);
	
	DualUse = СокрЛП(WorkSheet.Cells(10, 12).Text);
	
	CustomsRegime = СокрЛП(WorkSheet.Cells(13, 12).Text);
	
	ReasonForExport = СокрЛП(WorkSheet.Cells(14, 12).Text);
	           	
	
	// Section 2 Package Information
	Состояние("Section 2 Package Information...");
	
	НомерСтроки = 23;
	
	ТаблицаParcels.Очистить();	
	Пока Истина Цикл
		
		НоваяСтрокаТаблицыParcels = ТаблицаParcels.Добавить();
		
		НоваяСтрокаТаблицыParcels.PackageNumber = СокрЛП(WorkSheet.Cells(НомерСтроки, 2).Text);
		
		// Если Package number не заполнен - секция Parcels кончилась - выходим
		Если НЕ ЗначениеЗаполнено(НоваяСтрокаТаблицыParcels.PackageNumber) Тогда
			
			ТаблицаParcels.Удалить(НоваяСтрокаТаблицыParcels);
			Прервать;
			
		КонецЕсли;
		
		НоваяСтрокаТаблицыParcels.PackageType = СокрЛП(WorkSheet.Cells(НомерСтроки, 3).Text);
		
		НоваяСтрокаТаблицыParcels.Qty = WorkSheet.Cells(НомерСтроки, 4).Value;
		
		НоваяСтрокаТаблицыParcels.PackageGrossWeight = WorkSheet.Cells(НомерСтроки, 6).Value;
		
		НоваяСтрокаТаблицыParcels.Length = WorkSheet.Cells(НомерСтроки, 7).Value;
		
		НоваяСтрокаТаблицыParcels.Width = WorkSheet.Cells(НомерСтроки, 9).Value;
		
		НоваяСтрокаТаблицыParcels.Height = WorkSheet.Cells(НомерСтроки, 11).Value;
		
		НоваяСтрокаТаблицыParcels.EarliestPickupDate = СокрЛП(WorkSheet.Cells(НомерСтроки, 12).Text);

		НоваяСтрокаТаблицыParcels.LatestDeliveryDate = СокрЛП(WorkSheet.Cells(НомерСтроки, 13).Text);
		
		НоваяСтрокаТаблицыParcels.ShippingCountry = СокрЛП(WorkSheet.Cells(НомерСтроки, 14).Text);
		
		НоваяСтрокаТаблицыParcels.ShippingLocation = СокрЛП(WorkSheet.Cells(НомерСтроки, 15).Text);
		
		НоваяСтрокаТаблицыParcels.DestinationCountry = СокрЛП(WorkSheet.Cells(НомерСтроки, 16).Text);
		
		НоваяСтрокаТаблицыParcels.DestinationLocation = СокрЛП(WorkSheet.Cells(НомерСтроки, 17).Text);
		
		НомерСтроки = НомерСтроки + 1;
		
	КонецЦикла;  
	
	Если ТаблицаParcels.Количество() = 0 Тогда
		Сообщить("Failed to find any Parcel in the ""Section 2 Package Information""!");
		БылиКритическиеОшибки = Истина;
		Возврат;
	КонецЕсли;
	
	
	// Section 3 Items Information
	Состояние("Section 3 Items Information...");
	
	// Найдем начало секции
	НомерСтроки = НайтиНачалоСекции(БылиКритическиеОшибки, WorkSheet, НомерСтроки, "Section 3 Items Information");
	Если БылиКритическиеОшибки Тогда 
		Возврат;
	КонецЕсли;
	
	НомерСтроки = НомерСтроки + 3;
	ТаблицаItems.Очистить();
	Пока Истина Цикл
		
		НоваяСтрокаТаблицыItems = ТаблицаItems.Добавить();
		
		НоваяСтрокаТаблицыItems.PackageNumber = СокрЛП(WorkSheet.Cells(НомерСтроки, 2).Text);
		
		// Если Package number не заполнен - секция Items кончилась - выходим
		Если НЕ ЗначениеЗаполнено(НоваяСтрокаТаблицыItems.PackageNumber) Тогда
			
			ТаблицаItems.Удалить(НоваяСтрокаТаблицыItems);
			Прервать;
			
		КонецЕсли;
		
		НоваяСтрокаТаблицыItems.ItemType = СокрЛП(WorkSheet.Cells(НомерСтроки, 3).Text);
		
		НоваяСтрокаТаблицыItems.Qty = WorkSheet.Cells(НомерСтроки, 4).Value;
		
		НоваяСтрокаТаблицыItems.UnitUOM = ВРег(СокрЛП(WorkSheet.Cells(НомерСтроки, 5).Text));
		
		НоваяСтрокаТаблицыItems.HTCCode = СокрЛП(WorkSheet.Cells(НомерСтроки, 6).Text);
		
		НоваяСтрокаТаблицыItems.ItemDescription = СокрЛП(WorkSheet.Cells(НомерСтроки, 7).Text);
		
		НоваяСтрокаТаблицыItems.ImportSWPSPO = СокрЛП(WorkSheet.Cells(НомерСтроки, 12).Text);
		
		НоваяСтрокаТаблицыItems.NetWeight = WorkSheet.Cells(НомерСтроки, 13).Value;
		
		НоваяСтрокаТаблицыItems.AssetCode = СокрЛП(WorkSheet.Cells(НомерСтроки, 14).Text);
		
		НоваяСтрокаТаблицыItems.SerialNumber = СокрЛП(WorkSheet.Cells(НомерСтроки, 15).Text);
		
		НоваяСтрокаТаблицыItems.CountryOfOrigin = СокрЛП(WorkSheet.Cells(НомерСтроки, 16).Text);
		
		НоваяСтрокаТаблицыItems.Hazardous = WorkSheet.Cells(НомерСтроки, 17).Value;
		
		НоваяСтрокаТаблицыItems.Class = WorkSheet.Cells(НомерСтроки, 18).Value;
		
		НоваяСтрокаТаблицыItems.UnitPrice = WorkSheet.Cells(НомерСтроки, 20).Value;
		
		НоваяСтрокаТаблицыItems.Currency = ВРег(СокрЛП(WorkSheet.Cells(НомерСтроки, 21).Text));
				
		НомерСтроки = НомерСтроки + 1;
		
	КонецЦикла;
	
	Если ТаблицаItems.Количество() = 0 Тогда
		Сообщить("Failed to find any Item in the ""Section 3 Items Information""!");
		БылиКритическиеОшибки = Истина;
		Возврат;
	КонецЕсли;
	
	
	// Section 4 Comment
	Состояние("Section 4 Comment...");
	
	// Найдем начало 4й секции
	НомерСтроки = НайтиНачалоСекции(БылиКритическиеОшибки, WorkSheet, НомерСтроки, "Section 4 Comment");
	Если БылиКритическиеОшибки Тогда 
		Возврат;
	КонецЕсли;
	          	
	CargoComments = СокрЛП(WorkSheet.Cells(НомерСтроки+2, 5).Text);
	
	ShipperAddress = СокрЛП(WorkSheet.Cells(НомерСтроки+2, 13).Text);
	ShipperContact   = СокрЛП(WorkSheet.Cells(НомерСтроки+7, 13).Text);
	
	ShipToAddress = СокрЛП(WorkSheet.Cells(НомерСтроки+8, 13).Text);
	ShipToAttention = СокрЛП(WorkSheet.Cells(НомерСтроки+13, 13).Text);
	
	ConsignToAddress = СокрЛП(WorkSheet.Cells(НомерСтроки+2, 17).Text);
	ConsignToAttention = СокрЛП(WorkSheet.Cells(НомерСтроки+13, 17).Text);
	
	Состояние("Closing file...");
	Попытка
		Workbook.Close(False);
	Исключение
		Сообщить("Failed to close Excel Workbook!
			|" + ОписаниеОшибки());
		БылиНедочеты = Истина;
		Возврат;
	КонецПопытки;
	
	Попытка
		Workbooks.Close();
	Исключение
		Сообщить("Failed to close Excel Workbooks!
			|" + ОписаниеОшибки());
		БылиНедочеты = Истина;
		Возврат;
	КонецПопытки;
	
	Состояние("Closing Excel...");
	Попытка
		Excel.Quit();
	Исключение
		Сообщить("Failed to close Excel!
			|" + ОписаниеОшибки());
		БылиНедочеты = Истина;
		Возврат;
	КонецПопытки;
		
КонецПроцедуры

&НаКлиенте
Функция НайтиНачалоСекции(БылиКритическиеОшибки, WorkSheet, Знач НомерСтроки, НазваниеСекции)
	
	ПредельныйНомерСтроки = НомерСтроки + 10;
	
	Для НомерСтроки = НомерСтроки по ПредельныйНомерСтроки Цикл 
		
		Если СокрЛП(WorkSheet.Cells(НомерСтроки,2).Text) = НазваниеСекции Тогда 
			Возврат НомерСтроки;
		КонецЕсли;
		         				
	КонецЦикла;
	
	Сообщить("Failed to find '" + НазваниеСекции + "'!");
	БылиКритическиеОшибки = Истина;
	
	Возврат НомерСтроки;
	
КонецФункции

// ПОДГОТОВКА ПРОЧИТАННЫХ ДАННЫХ

&НаКлиенте
Процедура ПодготовитьТекстовыеРеквизитыИТаблицы(БылиКритическиеОшибки, БылиНедочеты)
	
	// BORG
	ПозицияРазделителя = СтрНайти(BORG,"-");
	Если ПозицияРазделителя > 0 Тогда 
		BORG = Лев(BORG, ПозицияРазделителя-1);
		BoRG = СокрП(BORG);
	КонецЕсли;
	
	// AU
	Пока СтрДлина(AU) < 7 Цикл 
		AU = "0" + AU;
	КонецЦикла;	
	
	// Parcels
	ShippingCountry = "";
	DestinationCountry = "";
	Если ТаблицаParcels.Количество() Тогда
			
		Для Каждого СтрокаТаблицыParcels Из ТаблицаParcels Цикл
			
			Если ЗначениеЗаполнено(СтрокаТаблицыParcels.ShippingCountry) Тогда
				
				Если ЗначениеЗаполнено(ShippingCountry) Тогда
					
					Если ShippingCountry <> СтрокаТаблицыParcels.ShippingCountry Тогда
						
						ShippingCountry = "";
						БылиНедочеты = Истина;
						Сообщить("Failed to determine Shipping country:
							|there are different shipping countires in Section 2 Package Information!");
						Прервать;
							
					КонецЕсли;
					
				Иначе
					ShippingCountry = СтрокаТаблицыParcels.ShippingCountry;
				КонецЕсли;
				
			КонецЕсли;
			
			Если ЗначениеЗаполнено(СтрокаТаблицыParcels.DestinationCountry) Тогда
				
				Если ЗначениеЗаполнено(DestinationCountry) Тогда
					
					Если DestinationCountry <> СтрокаТаблицыParcels.DestinationCountry Тогда
						
						DestinationCountry = "";
						БылиНедочеты = Истина;
						Сообщить("Failed to determine Destination country:
							|there are different destination countires in Section 2 Package Information!");
						Прервать;
							
					КонецЕсли;
					
				Иначе
					DestinationCountry = СтрокаТаблицыParcels.DestinationCountry;
				КонецЕсли;
				
			КонецЕсли;
			
		КонецЦикла;
		
	Иначе
		БылиКритическиеОшибки = Истина;
		Сообщить("Failed to find any Parcel in Section 2 Package Information!");
	КонецЕсли;
	
	// Items
	Если ТаблицаItems.Количество() Тогда
		
		Для Каждого СтрокаТаблицыItems Из ТаблицаItems Цикл
			
			// Unit UOM
			ПозицияТире = СтрНайти(СтрокаТаблицыItems.UnitUOM, "-");
			Если ПозицияТире > 0 Тогда
				СтрокаТаблицыItems.UnitUOM = Лев(СтрокаТаблицыItems.UnitUOM, ПозицияТире-1);
				СтрокаТаблицыItems.UnitUOM = СокрП(СтрокаТаблицыItems.UnitUOM);
			КонецЕсли;
			
		КонецЦикла;
		
	Иначе
		БылиКритическиеОшибки = Истина;
		Сообщить("Failed to find any Item in Section 3 Items Information!");
	КонецЕсли;
		
КонецПроцедуры


// СОЗДАНИЕ ОБЪЕКТОВ

&НаСервере
Функция СоздатьОбъектыБазыИзВременныхТаблиц(БылиКритическиеОшибки, БылиНедочеты, ПолныйПутьКФайлу, УниверсальноеВремяИзменения, АдресФайла) 
	
	НачатьТранзакцию(РежимУправленияБлокировкойДанных.Управляемый);	
	
	СтруктураДанныхБазы = ПолучитьСтруктуруДанныхБазы(БылиКритическиеОшибки, БылиНедочеты);
	
	ExportRequestОбъект = Документы.ExportRequest.СоздатьДокумент();
	
	ЗаполнитьИЗаписатьExportRequest(БылиКритическиеОшибки, БылиНедочеты, ExportRequestОбъект, СтруктураДанныхБазы);
	
	Если БылиКритическиеОшибки Тогда
		ОтменитьТранзакцию();
		Возврат Неопределено;
	КонецЕсли;
	
	СоздатьParcelsAndItems(БылиКритическиеОшибки, БылиНедочеты, ExportRequestОбъект, СтруктураДанныхБазы);
	
	Если БылиКритическиеОшибки Тогда 
		ОтменитьТранзакцию();
		Возврат Неопределено;
	КонецЕсли;
	
	// Прикрепим файл	
	Файл = Новый Файл(ПолныйПутьКФайлу);
	Попытка
		ПрисоединенныеФайлы.ДобавитьФайл(
			ExportRequestОбъект.Ссылка,
			Файл.ИмяБезРасширения,
			ОбщегоНазначенияКлиентСервер.РасширениеБезТочки(Файл.Расширение),
			ТекущаяДата(),
			УниверсальноеВремяИзменения,
			АдресФайла);		
	Исключение
		ОтменитьТранзакцию();
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Failed to attach file to """ + ExportRequestОбъект + "!
			|You should do it manually!
			|" + ОписаниеОшибки(),
			,,, БылиКритическиеОшибки);
		Возврат Неопределено;
	КонецПопытки;
	
	ЗафиксироватьТранзакцию();
	
	Возврат ExportRequestОбъект.Ссылка;
					
КонецФункции

&НаСервере
Функция ПолучитьСтруктуруДанныхБазы(БылиКритическиОшибки, БылиНедочеты)
	
	СтруктураПараметров = Новый Структура;
	СтруктураТекстов = Новый Структура;
	
	Если ЗначениеЗаполнено(ShippingCountry) Тогда
		
		СтруктураПараметров.Вставить("ShippingCountry", ShippingCountry);
		СтруктураТекстов.Вставить("FromCountry",
			"ВЫБРАТЬ
			|	CountriesOfProcessLevels.Ссылка
			|ИЗ
			|	Справочник.CountriesOfProcessLevels КАК CountriesOfProcessLevels
			|ГДЕ
			|	(НЕ CountriesOfProcessLevels.ПометкаУдаления)
			|	И CountriesOfProcessLevels.NameForMoveIT = &ShippingCountry");
		
	Иначе
			
		Сообщить("Failed to find From country,
			|because Shipping country is empty!");
		БылиНедочеты = Истина;
		
	КонецЕсли;
	
	Если ЗначениеЗаполнено(InvoiceToEntity) Тогда
		
		СтруктураПараметров.Вставить("InvoiceToEntity", InvoiceToEntity);
		СтруктураТекстов.Вставить("CompanyShipper",
			"ВЫБРАТЬ
			|	LegalEntities.Ссылка КАК Company,
			|	ConsignTo.Ссылка КАК Shipper
			|ИЗ
			|	Справочник.SoldTo КАК LegalEntities
			|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ConsignTo КАК ConsignTo
			|		ПО LegalEntities.Ссылка = ConsignTo.Владелец
			|			И ((НЕ ConsignTo.ПометкаУдаления))
			|ГДЕ
			|	LegalEntities.NameForMoveIt = &InvoiceToEntity
			|	И (НЕ LegalEntities.ПометкаУдаления)");
			
	Иначе
			
		Сообщить("Failed to find Company and Shipper,
			|because Invoice to Entity is empty!");
		БылиНедочеты = Истина;
			
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Segment) Тогда
		
		СтруктураПараметров.Вставить("Segment", Segment);
		СтруктураТекстов.Вставить("Segment",
			"ВЫБРАТЬ
			|	Сегменты.Ссылка
			|ИЗ
			|	Справочник.Сегменты КАК Сегменты
			|ГДЕ
			|	Сегменты.Код = &Segment
			|	И НЕ Сегменты.ПометкаУдаления
			|	И Сегменты.ЭтоГруппа
			|	И Сегменты.Родитель = ЗНАЧЕНИЕ(Справочник.Сегменты.ПустаяСсылка)");
		
	Иначе
		
		Сообщить("Segment is empty!");
		БылиНедочеты = Истина;
		
	КонецЕсли;

	Если ЗначениеЗаполнено(BORG) Тогда
		
		СтруктураПараметров.Вставить("BORG", BORG);
		СтруктураТекстов.Вставить("BORG",
			"ВЫБРАТЬ
			|	BORGs.Ссылка
			|ИЗ
			|	Справочник.BORGs КАК BORGs
			|ГДЕ
			|	BORGs.Код = &BORG
			|	И (НЕ BORGs.ПометкаУдаления)");
		
	Иначе
		
		Сообщить("Failed to find BORG,
			|because SWPS BORG is empty!");
		БылиНедочеты = Истина;
		
	КонецЕсли;
	
	Если ЗначениеЗаполнено(AU) Тогда
		
		СтруктураПараметров.Вставить("AU", AU);
		//-> RG-Soft VIvanov 2015/02/18
		СтруктураПараметров.Вставить("Дата", ТекущаяДата());
		СтруктураТекстов.Вставить("AU",
			//"ВЫБРАТЬ
			//|	AUs.Ссылка
			//|ИЗ
			//|	Справочник.КостЦентры КАК AUs
			//|ГДЕ
			//|	AUs.Код = &AU
			//|	И (НЕ AUs.ПометкаУдаления)");
		    "ВЫБРАТЬ
		    |	СегментыКостЦентровСрезПоследних.КостЦентр КАК Ссылка
		    |ИЗ
		    |	РегистрСведений.СегментыКостЦентров.СрезПоследних(&Дата, Код = &AU) КАК СегментыКостЦентровСрезПоследних
		    |ГДЕ
		    |	НЕ СегментыКостЦентровСрезПоследних.КостЦентр.ПометкаУдаления");
			 //<- RG-Soft VIvanov
	Иначе
		
		Сообщить("Failed to find AU,
			|because Accounting unit is empty!");
		БылиНедочеты = Истина;
		
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ReasonForExport) Тогда
		
		СтруктураПараметров.Вставить("ReasonForExport", ReasonForExport);
		СтруктураТекстов.Вставить("ExportPurpose", 
			"ВЫБРАТЬ
			|	ExportPurposes.Ссылка
			|ИЗ
			|	Справочник.ExportPurposes КАК ExportPurposes
			|ГДЕ
			|	ExportPurposes.MoveITName = &ReasonForExport
			|	И (НЕ ExportPurposes.ПометкаУдаления)");
		
	Иначе
		
		Сообщить("Failed to find Export purpose,
			|because Reason for export is empty!");
		БылиНедочеты = Истина;
		
	КонецЕсли;
	
	Если ЗначениеЗаполнено(DestinationCountry) Тогда
		
		СтруктураПараметров.Вставить("DestinationCountry", DestinationCountry);
		СтруктураТекстов.Вставить("POA",
			"ВЫБРАТЬ
			|	CountriesHUBs.Ссылка
			|ИЗ
			|	Справочник.CountriesHUBs КАК CountriesHUBs
			|ГДЕ
			|	(НЕ CountriesHUBs.ПометкаУдаления)
			|	И CountriesHUBs.NameForMoveIT = &DestinationCountry");
			
	Иначе
		
		Сообщить("Failed to find POA,
			|because Destination country is empty!");
		БылиНедочеты = Истина;
		
	КонецЕсли;
	
	МассивUOMs = РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ТаблицаItems, "UnitUOM");
	Если МассивUOMs.Количество() > 0 Тогда
		
		СтруктураПараметров.Вставить("МассивUOMs", МассивUOMs);
		СтруктураТекстов.Вставить("UOMs",
			"ВЫБРАТЬ
			|	UOMs.Ссылка,
			|	ВЫРАЗИТЬ(UOMs.Код КАК СТРОКА(3)) КАК Код
			|ИЗ
			|	Справочник.UOMs КАК UOMs
			|ГДЕ
			|	UOMs.Код В(&МассивUOMs)
			|	И (НЕ UOMs.ПометкаУдаления)");
		
	КонецЕсли;
	
	МассивCurrencies = РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ТаблицаItems, "Currency");
	Если МассивCurrencies.Количество() > 0 Тогда
		
		СтруктураПараметров.Вставить("МассивCurrencies", МассивCurrencies);
		СтруктураТекстов.Вставить("Currencies", 
			"ВЫБРАТЬ
			|	Валюты.Ссылка,
			|	Валюты.Наименование
			|ИЗ
			|	Справочник.Валюты КАК Валюты
			|ГДЕ
			|	Валюты.Наименование В(&МассивCurrencies)
			|	И (НЕ Валюты.ПометкаУдаления)");
		
	КонецЕсли;

	МассивClasses = РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ТаблицаItems, "Class");
	Если МассивClasses.Количество() > 0 Тогда
		
		СтруктураПараметров.Вставить("МассивClasses", МассивClasses);
		СтруктураТекстов.Вставить("HazardClasses",
			"ВЫБРАТЬ
			|	HazardClasses.Ссылка,
			|	HazardClasses.Код КАК Код
			|ИЗ
			|	Справочник.HazardClasses КАК HazardClasses
			|ГДЕ
			|	HazardClasses.Код В(&МассивClasses)
			|	И (НЕ HazardClasses.ПометкаУдаления)");
		
	КонецЕсли;
		
	Если ЗначениеЗаполнено(RequesterLDAPAlias) Тогда
		
		СтруктураПараметров.Вставить("RequesterLDAPAlias", RequesterLDAPAlias);
		СтруктураТекстов.Вставить("Submitter",
			"ВЫБРАТЬ
			|	Users.Ссылка
			|ИЗ
			|	Справочник.Пользователи КАК Users
			|ГДЕ
			|	Users.Код = &RequesterLDAPAlias
			|	И (НЕ Users.ПометкаУдаления)");
			
	Иначе
		
		Сообщить("Failed to find Submitter,
			|because Requester LDAP Alias is empty!");
		БылиНедочеты = Истина;
		
	КонецЕсли;
		
	УстановитьПривилегированныйРежим(Истина);
	СтруктураРезультатов = РГСофт.ПолучитьСтруктуруРезультатовТекстовЗапросов(СтруктураТекстов, СтруктураПараметров);
	
	СтруктураДанных = Новый Структура("FromCountry, Company, Segment, BORG, AU, ExportPurpose, Shipper, POA, UOMs, Currencies, HazardClasses, Submitter");
	
	Если СтруктураРезультатов.Свойство("FromCountry") Тогда
		
		ВыборкаFromCountry = СтруктураРезультатов.FromCountry.Выбрать();
		Если ВыборкаFromCountry.Количество() = 0 Тогда
			Сообщить("Failed to find From country by " + ShippingCountry + "!");
			БылиНедочеты = Истина;
		ИначеЕсли ВыборкаFromCountry.Количество() > 1 Тогда
			Сообщить("Found several From countries by " + ShippingCountry + "!");
			БылиНедочеты = Истина;
		Иначе	
			ВыборкаFromCountry.Следующий();
			СтруктураДанных.FromCountry = ВыборкаFromCountry.Ссылка;
		КонецЕсли;
		
	КонецЕсли;
	
	Если СтруктураРезультатов.Свойство("CompanyShipper") Тогда
		
		ВыборкаCompanyShipper = СтруктураРезультатов.CompanyShipper.Выбрать();
		Если ВыборкаCompanyShipper.Количество() = 0 Тогда
			Сообщить("Failed to find Company by " + InvoiceToEntity + "!");
			БылиНедочеты = Истина;
		ИначеЕсли ВыборкаCompanyShipper.Количество() > 1 Тогда
			Сообщить("Found several Companies by " + InvoiceToEntity + "!");
			БылиНедочеты = Истина;
		Иначе	
			ВыборкаCompanyShipper.Следующий();
			СтруктураДанных.Company = ВыборкаCompanyShipper.Company;
			СтруктураДанных.Shipper = ВыборкаCompanyShipper.Shipper;
		КонецЕсли;
		
	КонецЕсли;
	
	Если СтруктураРезультатов.Свойство("Segment") Тогда
		
		ВыборкаSegment = СтруктураРезультатов.Segment.Выбрать();
		Если ВыборкаSegment.Количество() = 0 Тогда
			Сообщить("Failed to find Segment by code " + Segment + "!");
			БылиНедочеты = Истина;
		ИначеЕсли ВыборкаSegment.Количество() > 1 Тогда
			Сообщить("Found several Segments by code " + Segment + "!");
			БылиНедочеты = Истина;
		Иначе	
			ВыборкаSegment.Следующий();
			СтруктураДанных.Segment = ВыборкаSegment.Ссылка;
		КонецЕсли;
		
	КонецЕсли;

	Если СтруктураРезультатов.Свойство("BORG") Тогда
		
		ВыборкаBORG = СтруктураРезультатов.BORG.Выбрать();
		Если ВыборкаBORG.Количество() = 0 Тогда
			Сообщить("Failed to find BORG by code " + BORG + "!");
			БылиНедочеты = Истина;
		ИначеЕсли ВыборкаBORG.Количество() > 1 Тогда
			Сообщить("Found several BORGs by code " + BORG + "!");
			БылиНедочеты = Истина;
		Иначе	
			ВыборкаBORG.Следующий();
			СтруктураДанных.BORG = ВыборкаBORG.Ссылка;
		КонецЕсли;
		
	КонецЕсли;
	
	Если СтруктураРезультатов.Свойство("AU") Тогда
		
		ВыборкаAU = СтруктураРезультатов.AU.Выбрать();
		Если ВыборкаAU.Количество() = 0 Тогда
			Сообщить("Failed to find AU by code " + AU + "!");
			БылиНедочеты = Истина;
		ИначеЕсли ВыборкаAU.Количество() > 1 Тогда
			Сообщить("Found several AUs by code " + AU + "!");
			БылиНедочеты = Истина;
		Иначе	
			ВыборкаAU.Следующий();
			СтруктураДанных.AU = ВыборкаAU.Ссылка;
		КонецЕсли;
		
	КонецЕсли;

	Если СтруктураРезультатов.Свойство("ExportPurpose") Тогда
		
		ВыборкаExportPurpose = СтруктураРезультатов.ExportPurpose.Выбрать();
		Если ВыборкаExportPurpose.Количество() = 0 Тогда
			Сообщить("Failed to find Export purpose by " + ReasonForExport + "!");
			БылиНедочеты = Истина;
		ИначеЕсли ВыборкаExportPurpose.Количество() > 1 Тогда
			Сообщить("Found several Export purposes by " + ReasonForExport + "!");
			БылиНедочеты = Истина;
		Иначе	
			ВыборкаExportPurpose.Следующий();
			СтруктураДанных.ExportPurpose = ВыборкаExportPurpose.Ссылка;
		КонецЕсли;
		
	КонецЕсли;
	
	Если СтруктураРезультатов.Свойство("POA") Тогда
		
		ВыборкаPOA = СтруктураРезультатов.POA.Выбрать();
		Если ВыборкаPOA.Количество() = 0 Тогда
			Сообщить("Failed to find POA by " + DestinationCountry + "!");
			БылиНедочеты = Истина;
		ИначеЕсли ВыборкаPOA.Количество() > 1 Тогда
			Сообщить("Found several POAs by " + DestinationCountry + "!");
			БылиНедочеты = Истина;
		Иначе	
			ВыборкаPOA.Следующий();
			СтруктураДанных.POA = ВыборкаPOA.Ссылка;
		КонецЕсли;
		
	КонецЕсли;
	
	Если СтруктураРезультатов.Свойство("UOMs") Тогда
		
		СтруктураДанных.UOMs = СтруктураРезультатов.UOMs.Выгрузить();
		Для Каждого СтрокаТаблицы Из СтруктураДанных.UOMs Цикл
			СтрокаТаблицы.Код = ВРег(СокрЛП(СтрокаТаблицы.Код));			 
		КонецЦикла;
		СтруктураДанных.UOMs.Индексы.Добавить("Код");
		
	КонецЕсли;
	
	Если СтруктураРезультатов.Свойство("Currencies") Тогда
		
		СтруктураДанных.Currencies = СтруктураРезультатов.Currencies.Выгрузить();
		Для Каждого СтрокаТаблицы Из СтруктураДанных.Currencies Цикл
			СтрокаТаблицы.Наименование = ВРег(СокрЛП(СтрокаТаблицы.Наименование));			 
		КонецЦикла;
		СтруктураДанных.Currencies.Индексы.Добавить("Наименование");
		
	КонецЕсли;
	
	Если СтруктураРезультатов.Свойство("HazardClasses") Тогда
		
		СтруктураДанных.HazardClasses = СтруктураРезультатов.HazardClasses.Выгрузить();
		СтруктураДанных.HazardClasses.Индексы.Добавить("Код");
		
	КонецЕсли;
	
	Если СтруктураРезультатов.Свойство("Submitter") Тогда
		
		ВыборкаSubmitter = СтруктураРезультатов.Submitter.Выбрать();
		Если ВыборкаSubmitter.Количество() = 0 Тогда
			Сообщить("Failed to find Submitter by " + RequesterLDAPAlias + "!");
			БылиНедочеты = Истина;
		ИначеЕсли ВыборкаSubmitter.Количество() > 1 Тогда
			Сообщить("Found several Submitters by " + RequesterLDAPAlias + "!");
			БылиНедочеты = Истина;
		Иначе	
			ВыборкаSubmitter.Следующий();
			СтруктураДанных.Submitter = ВыборкаSubmitter.Ссылка;
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат СтруктураДанных;
	
КонецФункции

&НаСервере
Функция ЗаполнитьИЗаписатьExportRequest(БылиКритическиеОшибки, БылиНедочеты, ExportRequestОбъект, СтруктураДанных)
	
	// From country
	ExportRequestОбъект.FromCountry = СтруктураДанных.FromCountry;
	
	// Company
	ExportRequestОбъект.Company = СтруктураДанных.Company;
	
	// Segment
	ExportRequestОбъект.Segment = СтруктураДанных.Segment;
	
	// BORG
	ExportRequestОбъект.BORG = СтруктураДанных.BORG;
	
	// AU
	ExportRequestОбъект.AU = СтруктураДанных.AU;
	
	// Activity
	ExportRequestОбъект.Activity = Activity; 
	
	// Export purpose
	ExportRequestОбъект.ExportPurpose = СтруктураДанных.ExportPurpose;
	
	// Export mode
	Если ЗначениеЗаполнено(CustomsRegime) Тогда
		
		Если НРег(CustomsRegime) = "permanent" ИЛИ НРег(CustomsRegime) = "temporary" Тогда
			ExportRequestОбъект.ExportMode = Перечисления.PermanentTemporary[CustomsRegime];
		Иначе			
			Сообщить("Unknown Customs regime """ + CustomsRegime + """!");
			БылиНедочеты = Истина;
		КонецЕсли;
		
	Иначе
		
		Сообщить("Failed to find Export mode,
			|because Customs regime is empty!");
		БылиНедочеты = Истина;
		
	КонецЕсли;
	
	// Dual use
	Если ЗначениеЗаполнено(DualUse) Тогда
		
		Если DualUse = "Yes" ИЛИ DualUse = "No" Тогда
			ExportRequestОбъект.DualUse = Перечисления.YesNo[DualUse];
		Иначе
			Сообщить("Unknown Dual use """ + DualUse + """!");
			БылиНедочеты = Истина;
		КонецЕсли;
		
	Иначе
		
		Сообщить("Failed to complete Dual use,
			|because Dual use items or licencable products is empty!");
		БылиНедочеты = Истина;
		
	КонецЕсли;
	
	// Shipper
	ExportRequestОбъект.Shipper = СтруктураДанных.Shipper;
	ExportRequestОбъект.ShipperContact = ShipperContact;
	
	// Pick up warehouse
	ExportRequestОбъект.PickUpWarehouse = Справочники.Warehouses.Other;
	
	// Pick up from address
	// Перечислим через запятую все различные Shipping location
	ТаблицаShippingLocation = ТаблицаParcels.Выгрузить(, "ShippingLocation");
	ТаблицаShippingLocation.Свернуть("ShippingLocation");
	Для Каждого СтрокаТаблицы Из ТаблицаShippingLocation Цикл
		Если ЗначениеЗаполнено(СтрокаТаблицы.ShippingLocation) Тогда
			ExportRequestОбъект.PickUpFromAddress = ExportRequestОбъект.PickUpFromAddress + ", " + СтрокаТаблицы.ShippingLocation;
		КонецЕсли;
	КонецЦикла;
	Если ЗначениеЗаполнено(ExportRequestОбъект.PickUpFromAddress) Тогда
		ExportRequestОбъект.PickUpFromAddress = Сред(ExportRequestОбъект.PickUpFromAddress, 3);
	КонецЕсли;
	
	// Ready to ship date and Required delivery date
	ReadyToShipDate = '00010101';
	RequiredDeliveryDate = '00010101';
	Для Каждого СтрокаТаблицыParcel Из ТаблицаParcels Цикл
		
		Если ЗначениеЗаполнено(СтрокаТаблицыParcel.EarliestPickupDate) Тогда
			
			EarliestPickupDate = ПолучитьДатуИзСтроки(СтрокаТаблицыParcel.EarliestPickupDate);
			Если EarliestPickupDate = Неопределено Тогда
				Сообщить("Failed to convert """ + СтрокаТаблицыParcel.EarliestPickupDate + """ to Ready to ship date!");
				БылиНедочеты = Истина;
			ИначеЕсли EarliestPickupDate > ReadyToShipDate Тогда
				ReadyToShipDate = EarliestPickupDate;
			КонецЕсли;
			
		КонецЕсли;
		
		Если ЗначениеЗаполнено(СтрокаТаблицыParcel.LatestDeliveryDate) Тогда
			
			LatestDeliveryDate = ПолучитьДатуИзСтроки(СтрокаТаблицыParcel.LatestDeliveryDate);
			Если LatestDeliveryDate = Неопределено Тогда
				Сообщить("Failed to convert """ + СтрокаТаблицыParcel.LatestDeliveryDate + """ to Required delivery date!");
				БылиНедочеты = Истина;
			ИначеЕсли НЕ ЗначениеЗаполнено(RequiredDeliveryDate) ИЛИ LatestDeliveryDate < RequiredDeliveryDate Тогда
				RequiredDeliveryDate = LatestDeliveryDate;
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЦикла;
	
	Если ЗначениеЗаполнено(ReadyToShipDate) Тогда
		ExportRequestОбъект.ReadyToShipDate = ReadyToShipDate;	
	Иначе
		Сообщить("Failed to fill Ready to ship date!");
		БылиНедочеты = Истина;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(RequiredDeliveryDate) Тогда
		ExportRequestОбъект.RequiredDeliveryDate = RequiredDeliveryDate;	
	Иначе
		Сообщить("Failed to fill Required delivery date!");
		БылиНедочеты = Истина;
	КонецЕсли;
	
	// POA
	ExportRequestОбъект.POA = СтруктураДанных.POA;
	
	// Deliver to
	ExportRequestОбъект.DeliverTo = Справочники.Shippers.Other;
	ExportRequestОбъект.DeliverToContact = ShipToAttention;
	ExportRequestОбъект.DeliverToAddress = ShipToAddress;
	
	// Consignee
	ExportRequestОбъект.Consignee = Справочники.Shippers.Other;
	ExportRequestОбъект.ConsigneeContact = ConsignToAttention;
	ExportRequestОбъект.ConsigneeAddress = ConsignToAddress;	
	
	// Submitter
	ExportRequestОбъект.Submitter = СтруктураДанных.Submitter;
	
	// Export specialist
	ExportRequestОбъект.ExportSpecialist = ПараметрыСеанса.ТекущийПользователь;
	
	// Comments
	ExportRequestОбъект.Comments = СокрЛП(CargoComments);
	
	ExportRequestОбъект.LoadedFromCBR = Истина;
	
	// Попробуем записать
	Попытка
		ExportRequestОбъект.Записать();
	Исключение
		Сообщить("Failed to save """ + ExportRequestОбъект + """!
			|" + ОписаниеОшибки());
		БылиКритическиеОшибки = Истина;
	КонецПопытки;

КонецФункции 

&НаСервере
Процедура СоздатьParcelsAndItems(БылиКритическиеОшибки, БылиНедочеты, ExportRequestОбъект, СтруктураДанных)
	
	СтруктураПоискаПоPackageNumber = Новый Структура("PackageNumber");
	KG = Справочники.UOMs.KG;

	Пока ТаблицаParcels.Количество() Цикл
		
		СтрокаТаблицыParcels = ТаблицаParcels[0];
		
		ParcelОбъект = Справочники.Parcels.СоздатьЭлемент();
		
		// Заполним шапку парселя
		ParcelОбъект.ExportRequest = ExportRequestОбъект.Ссылка;
		ParcelОбъект.Код           = СокрЛП(ExportRequestОбъект.Номер) + "-" + СтрокаТаблицыParcels.PackageNumber;
		ParcelОбъект.NumOfParcels  = СтрокаТаблицыParcels.Qty;
		ParcelОбъект.PackingType   = ImportExportСерверПовтИспСеанс.ПолучитьPackingTypeПоКоду(СтрокаТаблицыParcels.PackageType);
		ParcelОбъект.GrossWeight   = СтрокаТаблицыParcels.PackageGrossWeight;
		ParcelОбъект.WeightUOM	   = Справочники.UOMs.KG;
	    ParcelОбъект.Length   	   = СтрокаТаблицыParcels.Length;
	    ParcelОбъект.Width  	   = СтрокаТаблицыParcels.Width;
		ParcelОбъект.Height   	   = СтрокаТаблицыParcels.Height;
		ParcelОбъект.DIMsUOM	   = Справочники.UOMs.CM;
		
		// Заполним табличную часть парселя
		СтруктураПоискаПоPackageNumber.PackageNumber = СтрокаТаблицыParcels.PackageNumber;
		СтрокиТаблицыItems = ТаблицаItems.НайтиСтроки(СтруктураПоискаПоPackageNumber);
		Если СтрокиТаблицыItems.Количество() = 0 Тогда
			Сообщить("Failed to find Items of Parcel " + СтрокаТаблицыParcels.PackageNumber + "!");
			БылиКритическиеОшибки = Истина;
			Возврат;
		КонецЕсли;
		
		MaxHazardClass = 0;
		
		// Создадим товары
		Для Каждого СтрокаТаблицыItems Из СтрокиТаблицыItems Цикл
			
			ItemОбъект = Справочники.СтрокиИнвойса.СоздатьЭлемент();
			
			ItemОбъект.ExportRequest = ExportRequestОбъект.Ссылка;
			ItemОбъект.Классификатор = ПолучитьТипЗаказа(СтрокаТаблицыItems.ItemType);
			ItemОбъект.Количество = СтрокаТаблицыItems.Qty;
			ItemОбъект.МеждународныйКодТНВЭД = СтрокаТаблицыItems.HTCCode;
			ItemОбъект.НаименованиеТовара    = СтрокаТаблицыItems.ItemDescription;
            ItemОбъект.ImportReference       = СтрокаТаблицыItems.ImportSWPSPO;
            ItemОбъект.NetWeight             = СтрокаТаблицыItems.NetWeight;
			ItemОбъект.WeightUOM             = KG;
			ItemОбъект.КодПоИнвойсу          = СтрокаТаблицыItems.AssetCode;
			ItemОбъект.СерийныйНомер         = СтрокаТаблицыItems.SerialNumber;
            ItemОбъект.СтранаПроисхождения   = СтрокаТаблицыItems.CountryOfOrigin;
			ItemОбъект.Цена                  = СтрокаТаблицыItems.UnitPrice;
			ItemОбъект.Сумма				 = ItemОбъект.Цена * ItemОбъект.Количество;
			
			// UOM
			СтрокаUOMs = СтруктураДанных.UOMs.Найти(СтрокаТаблицыItems.UnitUOM, "Код");
			Если СтрокаUOMs = Неопределено Тогда 
				Сообщить("Failed to find UOM by code """ + СтрокаТаблицыItems.UnitUOM + """!");
				БылиНедочеты = Истина;
			Иначе
				ItemОбъект.ЕдиницаИзмерения = СтрокаUOMs.Ссылка;
			КонецЕсли;
			
			// Currency
			Если ЗначениеЗаполнено(СтрокаТаблицыItems.Currency) Тогда
				
				СтрокаCurrencies = СтруктураДанных.Currencies.Найти(СтрокаТаблицыItems.Currency, "Наименование");
				Если СтрокаCurrencies = Неопределено Тогда 
					Сообщить("Failed to find Currency by code """ + СтрокаТаблицыItems.Currency + """!");
					БылиНедочеты = Истина;
				Иначе
					ItemОбъект.Currency = СтрокаCurrencies.Ссылка;
				КонецЕсли;
				
			КонецЕсли;
				
			Попытка
				ItemОбъект.Записать();
			Исключение
				Сообщить("Failed to save Item!
					|" + ОписаниеОшибки());
				БылиКритическиеОшибки = Истина;
				Возврат;
			КонецПопытки;
			
			// Hazard class
			Если СтрокаТаблицыItems.Hazardous = "Yes" Тогда
				
				Если ЗначениеЗаполнено(СтрокаТаблицыItems.Class) Тогда
					Если СтрокаТаблицыItems.Class > MaxHazardClass Тогда
						MaxHazardClass = СтрокаТаблицыItems.Class;
					КонецЕсли;
				Иначе
					Сообщить("Failed to determine hazard class of Item """ + СокрЛП(ItemОбъект) + """!");
					БылиНедочеты = Истина;
				КонецЕсли;
				
			КонецЕсли;
			
			ТаблицаItems.Удалить(СтрокаТаблицыItems);
			
			НоваяСтрока = ParcelОбъект.Детали.Добавить();
			НоваяСтрока.СтрокаИнвойса = ItemОбъект.Ссылка;
			НоваяСтрока.СерийныйНомер = ItemОбъект.СерийныйНомер;
			НоваяСтрока.Qty           = ItemОбъект.Количество;
           	НоваяСтрока.QtyUOM        = ItemОбъект.ЕдиницаИзмерения;
            НоваяСтрока.NetWeight     = ItemОбъект.NetWeight;
            
			ParcelОбъект.NetWeight = ParcelОбъект.NetWeight + НоваяСтрока.NetWeight;
			
		КонецЦикла;
		
		// Hazard class
		Если ЗначениеЗаполнено(MaxHazardClass) Тогда
			СтрокаHazardClasses = СтруктураДанных.HazardClasses.Найти(MaxHazardClass, "Код");
			Если СтрокаHazardClasses = Неопределено Тогда
				Сообщить("Failed to find Hazard class by code """ + MaxHazardClass + """!");
				БылиНедочеты = Истина;
			Иначе
				ParcelОбъект.HazardClass = СтрокаHazardClasses.Ссылка;
			КонецЕсли;
		КонецЕсли;
		
		Попытка
			ParcelОбъект.Записать();
		Исключение
			Сообщить("Failed to save Parcel #" + СтрокаТаблицыParcels.PackageNumber + "!
				|" + ОписаниеОшибки());
			БылиКритическиеОшибки = Истина;
			Возврат;
		КонецПопытки;
		
		ТаблицаParcels.Удалить(0);
		
	КонецЦикла;

	Если ТаблицаItems.Количество() Тогда
		Сообщить("Failed to put some items in parcels!
			|Maybe wrong package number?");
		БылиКритическиеОшибки = Истина;
	КонецЕсли;
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьТипЗаказа(ItemType)
	
	Если ItemType = "Asset Under Construction (FTE)" тогда
		Возврат Перечисления.ТипыЗаказа.V;
		
	ИначеЕсли ItemType = "Asset Under Construction (NFTE)" тогда
		Возврат Перечисления.ТипыЗаказа.U;
		
	ИначеЕсли ItemType = "Chemical" тогда
		Возврат Перечисления.ТипыЗаказа.I;
		
	ИначеЕсли ItemType = "Explosive" тогда
		Возврат Перечисления.ТипыЗаказа.I;
		
	ИначеЕсли ItemType = "M&S" тогда
		Возврат Перечисления.ТипыЗаказа.E;
		
	ИначеЕсли ItemType = "New Asset (FTE)" тогда
		Возврат Перечисления.ТипыЗаказа.A;
		
	ИначеЕсли ItemType = "New Asset (NFTE)" тогда
		Возврат Перечисления.ТипыЗаказа.A;
		
	ИначеЕсли ItemType = "New Inventory" тогда
		Возврат Перечисления.ТипыЗаказа.I;
		
	ИначеЕсли ItemType = "Used Asset" тогда
		Возврат Перечисления.ТипыЗаказа.FAT;
		
	ИначеЕсли ItemType = "Used Inventory" тогда
		Возврат Перечисления.ТипыЗаказа.FMT;
		
	Иначе
		Возврат Неопределено;
		
	КонецЕсли;
	
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьДатуИзСтроки(Знач ДатаСтрока) Экспорт
	
	ДатаСтрока = СокрЛП(ДатаСтрока);
	ПозицияРазделителя = СтрНайти(ДатаСтрока, "/");
	Если ПозицияРазделителя = 0 Тогда
		Возврат Неопределено;
	КонецЕсли;
			
	ДеньСтрока = Лев(ДатаСтрока, ПозицияРазделителя - 1);	
	Попытка
		День = Число(ДеньСтрока);
	Исключение
		Возврат Неопределено;
	КонецПопытки;
	
	ОставшаясяСтрока = СокрЛ(Сред(ДатаСтрока, ПозицияРазделителя+1));
		
	МесяцСтрока = Лев(ОставшаясяСтрока, 2);
	Попытка
		Месяц = Число(МесяцСтрока);
	Исключение
		Возврат Неопределено;
	КонецПопытки;
		
	ПозицияРазделителя = СтрНайти(ОставшаясяСтрока, "/");
	Если ПозицияРазделителя = 0 Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	ОставшаясяСтрока = СокрЛ(Сред(ОставшаясяСтрока, ПозицияРазделителя+1));
	ГодСтрока = Лев(ОставшаясяСтрока, 4);
	
	Попытка
		Год = Число(ГодСтрока);
	Исключение
		Возврат Неопределено;
	КонецПопытки;
	
	Попытка
		ИтоговаяДата = Дата(Год, Месяц, День);
	Исключение
		Возврат Неопределено;
	КонецПопытки;
	
	Возврат ИтоговаяДата;
			
КонецФункции
