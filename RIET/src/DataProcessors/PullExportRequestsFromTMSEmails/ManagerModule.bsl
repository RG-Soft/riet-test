            
///////////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТКА ПИСЕМ

// { RGS VChaplygin 15.04.2016 8:42:22 - Добавим аварийный почтовый аккаунт
//Функция ОбработатьПисьма(Письма, ИнтернетПочта, АдресОтправителя) Экспорт
Функция ОбработатьПисьма(Письма, ДанныеДляОтправкиОтвета) Экспорт
// } RGS VChaplygin 15.04.2016 8:42:40 - Добавим аварийный почтовый аккаунт
	
	// Обрабатывает переданные письма
	// Возвращает массив успешно обработанных писем
	// ИнтернетПочта и АдресОтправителя нужны для отправки ответа
	
	ОбработанныеПисьма = Новый Массив;
	
	Для Каждого Письмо Из Письма Цикл
		
		Если СтрНайти(Письмо.Тема, "[TMS Offline Service:Transport Request]:Shipment from") <> 1 Тогда
			Продолжить;
		КонецЕсли;
		
		// Письма должны обрабатываться независимо
		// Если при обработке письма случилась ошибка - это не должно повлиять на другое письмо
		Попытка
			
			// { RGS VChaplygin 15.04.2016 8:42:22 - Добавим аварийный почтовый аккаунт
			//ОбработатьПисьмо(Письмо, ИнтернетПочта, АдресОтправителя);
			ОбработатьПисьмо(Письмо, ДанныеДляОтправкиОтвета);
			// } RGS VChaplygin 15.04.2016 8:42:40 - Добавим аварийный почтовый аккаунт
			ОбработанныеПисьма.Добавить(Письмо);
			
		Исключение
			
			// Если при обработке письма была открыта транзакция и вылетело исключение - транзакцию небходимо отменить
			Если ТранзакцияАктивна() Тогда
				ОтменитьТранзакцию();
			КонецЕсли;
			
			// Залоггируем ошибку, чтобы получить ее по е-mail
			// { RGS vchaplygin 26.04.2018 8:29:29 - Говнище генерит в логах
			//РГСофт.СообщитьИЗалоггировать(
			//	"Failed to process incoming e-mail " + Письмо.Идентификатор[0],
			//	УровеньЖурналаРегистрации.Ошибка,
			//	Метаданные.Обработки.PullExportRequestsFromTMSEmails,
			//	Неопределено,
			//	ОписаниеОшибки());
			РГСофт.СообщитьИЗалоггировать(
				"Failed to process incoming e-mail. PullExportRequestsFromTMSEmails",
				УровеньЖурналаРегистрации.Ошибка,
				Метаданные.Обработки.PullExportRequestsFromTMSEmails,
				Неопределено,
				"Failed to process incoming e-mail: " + Письмо.Идентификатор[0] + "
					|" + ОписаниеОшибки()
				);
			// } RGS vchaplygin 26.04.2018 8:29:44 - Говнище генерит в логах
			
		КонецПопытки;
		
	КонецЦикла;
	
	Возврат ОбработанныеПисьма;
	
КонецФункции

// { RGS VChaplygin 15.04.2016 8:42:22 - Добавим аварийный почтовый аккаунт
//Процедура ОбработатьПисьмо(Письмо, ИнтернетПочта, АдресОтправителя)
Процедура ОбработатьПисьмо(Письмо, ДанныеДляОтправкиОтвета)
// } RGS VChaplygin 15.04.2016 8:42:40 - Добавим аварийный почтовый аккаунт
	
	// Обрабатывает письмо
	// ИнтернетПочта и АдресОтправителя нужны для отправки ответа
	
	// { RGS VChaplygin 15.04.2016 8:42:22 - Добавим аварийный почтовый аккаунт
	//ДанныеДляОтправкиОтвета = Новый Структура;
	//ДанныеДляОтправкиОтвета.Вставить("ИнтернетПочта", ИнтернетПочта);
	//ДанныеДляОтправкиОтвета.Вставить("АдресОтправителя", АдресОтправителя);
	//ДанныеДляОтправкиОтвета.Вставить("АдресПолучателя", Письмо.Отправитель.Адрес);
	//ДанныеДляОтправкиОтвета.Вставить("ТемаИсходногоПисьма", Письмо.Тема);
	ДанныеДляОтправкиОтвета.АдресПолучателя = Письмо.Отправитель.Адрес;
	ДанныеДляОтправкиОтвета.ТемаИсходногоПисьма = Письмо.Тема;
	// } RGS VChaplygin 15.04.2016 8:42:22 - Добавим аварийный почтовый аккаунт
	 		
	// Получим тело письма в виде простого текста
	ТекстПисьма = ImportExportСервер.ПолучитьПростойТекстПисьма(Письмо);
	Если ТекстПисьма = Неопределено Тогда
		ПослатьПисьмоОбОшибке(ДанныеДляОтправкиОтвета, "Only plain text body is allowed");
		Возврат;
	КонецЕсли;
		
	// Сделаем из простого текста структуру текстовых значений
	СтруктураПисьма = ПолучитьСтруктуруПисьма(СокрЛП(ТекстПисьма));
	
	// Если вернулась строка, а не структура - значит произошли ошибки
	Если ТипЗнч(СтруктураПисьма) = Тип("Строка") Тогда
		ПослатьПисьмоОбОшибке(ДанныеДляОтправкиОтвета, СтруктураПисьма);
		Возврат;
	КонецЕсли;
	
	// Дополним структуру письма
	СтруктураПисьма.Вставить("SubmitterEmail", Письмо.Отправитель.Адрес);
	СтруктураПисьма.Вставить("UID", Письмо.Идентификатор[0]);
	
	// Проверим структуру письма
	ТекстОшибок = ПроверитьСтруктуруТекстовыхЗначений(СтруктураПисьма);
	Если ТекстОшибок <> "" Тогда
		ПослатьПисьмоОбОшибке(ДанныеДляОтправкиОтвета, ТекстОшибок);
		Возврат;
	КонецЕсли;
			
	// Далее все происходит в транзакции: для целостности и чтобы избежать "грязного чтения"
	НачатьТранзакцию(РежимУправленияБлокировкойДанных.Управляемый);
			
	// Создадим объекты
	ExportRequestОбъект = СоздатьОбъекты(СтруктураПисьма);
	
	// Если вернулась строка, а не объект - значит произошли ошибки
	Если ТипЗнч(ExportRequestОбъект) = Тип("Строка") Тогда
		ОтменитьТранзакцию();
		ПослатьПисьмоОбОшибке(ДанныеДляОтправкиОтвета, ExportRequestОбъект);
		Возврат;
	КонецЕсли;
	
	ПослатьПисьмоОбУспехе(ДанныеДляОтправкиОтвета, СокрЛП(ExportRequestОбъект.Номер)); 
		
	ЗафиксироватьТранзакцию();
		
КонецПроцедуры


//////////////////////////////////////////////////////////////////////////////////////
// ТЕКСТ -> СТРУКТУРА
          
Функция ПолучитьСтруктуруПисьма(Текст)
	
	// Получает структуру письма из переданного текста
	// На верхем уровне структуры лежат реквизиты шапки
	// Внутри лежат реквизиты parcels
	// В parcels лежат реквизиты items
	// В случае ошибки возрващает текст ошибки
	
	ТекстовыйДок = Новый ТекстовыйДокумент(); 
	ТекстовыйДок.УстановитьТекст(Текст);
	
	СтруктураПисьма = Новый Структура(
		"TYPE, PICKUPDATE, DELIVERYDATE, TIMEZONE, SOURCE, DEST, PRIORITY, EXTERNALID, JOBNUM, INCOTERM, PAYING_ENTITY_FLAG, COMPNAME, LE, COMPNAME, COUNTRY, ERPID, FINLOCCODE, FINPROCESS, CUSTOMSSTATUS, EXPORTREGIME, CC, AC, TAX, PROJECT, NOTES, RECHARGE_FLAG, RECHARGE_AC, RECHARGE_COMM_AGRMT, RECHARGE_CC, RECHARGE_COUNTRY, RECHARGE_ERPID, RECHARGE_LOC_CODE, RECHARGE_FIN_PROCESS, RECHARGE_LE, InvolvedParties, Shipper, ShipperContact, PickUpFromContact, Consignee, Parcels, SourceEmail");
	СтруктураПисьма.InvolvedParties = Новый Массив;	
	СтруктураПисьма.Parcels = Новый Массив;
	СтруктураПисьма.SourceEmail = Текст;
			
	// Разбираем текст построчно
	ИдетШапки = Ложь;
	ИдетParcel = Ложь;
	ИдетItem = Ложь;
	ИдетInvolvedParty = Ложь;
	КоличествоСтрок = ТекстовыйДок.КоличествоСтрок();
	Для НомерСтроки = 1 По КоличествоСтрок Цикл
		
		Стр = СокрЛП(ТекстовыйДок.ПолучитьСтроку(НомерСтроки));
		
		// Определим, не входим ли мы в новую секцию
		Если Стр = "HD" Тогда
			
			ИдетШапка = Истина;
			ИдетInvolvedParty = Ложь;
			ИдетParcel = Ложь;
			ИдетItem = Ложь;
			
		ИначеЕсли Стр = "HD_INVOLVED_PARTY" Тогда
			
			СтруктураInvolvedParty = Новый Структура("INVOLVED_PARTY_QUALIFIER, INVOLVED_PARTY_LOCATION, CONTACT_ID, COMM_METHOD");
			СтруктураПисьма.InvolvedParties.Добавить(СтруктураInvolvedParty);
			
			ИдетШапка = Ложь;
			ИдетInvolvedParty = Истина;
			ИдетParcel = Ложь;
			ИдетItem = Ложь;
						
		ИначеЕсли Стр = "SHIPUNIT" Тогда
			
			СтруктураParcel = Новый Структура(
				"QTY, UOM, PACKAGE_SERIAL_NO, LEN, LENUOM, WD, WIDTHUOM, HT, HTUOM, GROSSWGT, GROSSWGTUOM, GROSSVOLUME, GROSSVOLUMEUOM, ITEMTYPE, Items");
			СтруктураParcel.Items = Новый Массив;
			СтруктураПисьма.Parcels.Добавить(СтруктураParcel);
				
			ИдетШапка = Ложь;
			ИдетInvolvedParty = Ложь;
			ИдетParcel = Истина;
			ИдетItem = Ложь;
			
		ИначеЕсли Стр = "LINEITEM" Тогда
			
			СтруктураItem = Новый Структура("PARTNUM, ASSETCODE, QTY, QTYUOM, NETWGT, NETWGTUOM, NETVOLUME, NETVOLUMEUOM, VALUE, CURR, SERIAL_NO, COO, RAN, LICNO, PONUM, PO_LINE");
			Если СтруктураParcel <> Неопределено Тогда
				СтруктураParcel.Items.Добавить(СтруктураItem);
			КонецЕсли;
			      			      			
			ИдетШапка = Ложь;
			ИдетInvolvedParty = Ложь;
			ИдетParcel = Ложь;
			ИдетItem = Истина;
			
		Иначе
			
			ПозицияРазделителя = СтрНайти(Стр, "=");
	
			Если ПозицияРазделителя = 0 Тогда
				Возврат "Unknown line " + Стр;		
			КонецЕсли;
			
			Ключ     = СокрЛП(Лев(Стр, ПозицияРазделителя-1));
			Значение = СокрЛП(Сред(Стр, ПозицияРазделителя+1));	
			
			Если ИдетШапка Тогда
			
				СтруктураПисьма.Вставить(Ключ, Значение);
				
			ИначеЕсли ИдетInvolvedParty Тогда
				
				СтруктураInvolvedParty.Вставить(Ключ, Значение);
										
			ИначеЕсли ИдетParcel Тогда
				
				СтруктураParcel.Вставить(Ключ, Значение);
				
			ИначеЕсли ИдетItem Тогда
				
				СтруктураItem.Вставить(Ключ, Значение);
				
			Иначе
				
				Возврат "Unknown section of line " + Стр;		
														       			
			КонецЕсли;
			
		КонецЕсли;
						
	КонецЦикла;
	
	// Вычленим Involved parties с известными qualifiers
	InvolvedParties = СтруктураПисьма.InvolvedParties;
	Индекс = 0;
	Пока Индекс < InvolvedParties.Количество() Цикл
		
		СтруктураInvolvedParty = InvolvedParties[Индекс];	
		
		Если СтруктураInvolvedParty.INVOLVED_PARTY_QUALIFIER = "EXPORTER" Тогда
			
			СтруктураПисьма.Shipper = СтруктураInvolvedParty.INVOLVED_PARTY_LOCATION;
			InvolvedParties.Удалить(Индекс);
			
		ИначеЕсли СтруктураInvolvedParty.INVOLVED_PARTY_QUALIFIER = "SLB.ORIGIN_SLS" Тогда
			
			СтруктураПисьма.ShipperContact = СтруктураInvolvedParty.CONTACT_ID;
			InvolvedParties.Удалить(Индекс);
			
		ИначеЕсли СтруктураInvolvedParty.INVOLVED_PARTY_QUALIFIER = "CONSIGNEE" Тогда
			
			СтруктураПисьма.Consignee = СтруктураInvolvedParty.INVOLVED_PARTY_LOCATION;
			InvolvedParties.Удалить(Индекс);
								
		Иначе
			
			Индекс = Индекс + 1;
			
		КонецЕсли;	
		
	КонецЦикла;
	
	Возврат СтруктураПисьма;
	
КонецФункции

// ДОДЕЛАТЬ
Функция ПроверитьСтруктуруТекстовыхЗначений(СтруктураПисьма)
			
	ТекстОшибок = "";
	
	// Header
	
	Если НЕ ЗначениеЗаполнено(СтруктураПисьма.TYPE) Тогда
		ДобавитьСтроку(ТекстОшибок, "Order Type is empty!");
	ИначеЕсли ВРег(СтруктураПисьма.Type) <> "GEN INTERNATIONAL" Тогда
		ДобавитьСтроку(ТекстОшибок, "Only 'General Cargo International' Order Type is supported!");
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(СтруктураПисьма.PRIORITY) Тогда
		ДобавитьСтроку(ТекстОшибок, "Priority is empty!");
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(СтруктураПисьма.PICKUPDATE) Тогда
		ДобавитьСтроку(ТекстОшибок, "Earliest Availability Date is empty!");
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(СтруктураПисьма.DELIVERYDATE) Тогда
		ДобавитьСтроку(ТекстОшибок, "Required Delivery Date is empty!");
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(СтруктураПисьма.SOURCE) Тогда
		ДобавитьСтроку(ТекстОшибок, "Source Location is empty!");
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(СтруктураПисьма.DEST) Тогда
		ДобавитьСтроку(ТекстОшибок, "Destination Location is empty!");
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(СтруктураПисьма.COMPNAME) Тогда
		
		ДобавитьСтроку(ТекстОшибок, "Legal Entity is empty!");
		
	Иначе
		
		Если НЕ ЗначениеЗаполнено(СтруктураПисьма.LE) Тогда
			ДобавитьСтроку(ТекстОшибок, "LE of " + СтруктураПисьма.COMPNAME + " is empty in Excel file!
				|Ask support team to check Excel file.");
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(СтруктураПисьма.COUNTRY) Тогда
			ДобавитьСтроку(ТекстОшибок, "COUNTRY of " + СтруктураПисьма.COMPNAME + " is empty in Excel file!
				|Ask support team to check Excel file.");
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(СтруктураПисьма.ERPID) Тогда
			ДобавитьСтроку(ТекстОшибок, "ERPID of " + СтруктураПисьма.COMPNAME + " is empty in Excel file!
				|Ask support team to check Excel file.");
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(СтруктураПисьма.FINLOCCODE) Тогда
			ДобавитьСтроку(ТекстОшибок, "FINLOCCODE of " + СтруктураПисьма.COMPNAME + " is empty in Excel file!
				|Ask support team to check Excel file.");
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(СтруктураПисьма.FINPROCESS) Тогда
			ДобавитьСтроку(ТекстОшибок, "FINPROCESS of " + СтруктураПисьма.COMPNAME + " is empty in Excel file!
				|Ask support team to check Excel file.");
		КонецЕсли;
		
	КонецЕсли;	
	
	Если НЕ ЗначениеЗаполнено(СтруктураПисьма.CC) Тогда
		ДобавитьСтроку(ТекстОшибок, "Cost Centre is empty!");
	КонецЕсли;
	
	Если СтруктураПисьма.Parcels.Количество() = 0 Тогда	
		ДобавитьСтроку(ТекстОшибок, "At least one ship. unit required!");
	КонецЕсли;
	
	// МОЖЕТ БЫТЬ ТРЕБОВАТЬ ЗАПОЛНЕНИЯ CONSIGNEE?
	
	НомерParcel = 0;
	Для Каждого СтруктураParcel Из СтруктураПисьма.Parcels Цикл
		
		НомерParcel = НомерParcel + 1;
		ПрефиксОшибки = "Ship. unit " + НомерParcel + ": ";
		
		Если НЕ ЗначениеЗаполнено(СтруктураParcel.ITEMTYPE) Тогда
			ДобавитьСтроку(ТекстОшибок, ПрефиксОшибки + "Item Type is empty!");
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(СтруктураParcel.QTY) Тогда
			ДобавитьСтроку(ТекстОшибок, ПрефиксОшибки + "Ship Unit Qty is empty!");
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(СтруктураParcel.UOM) Тогда
			ДобавитьСтроку(ТекстОшибок, ПрефиксОшибки + "Ship Unit is empty!");
		КонецЕсли;

		Если ЗначениеЗаполнено(СтруктураParcel.LEN) И НЕ ЗначениеЗаполнено(СтруктураParcel.LENUOM) Тогда
			ДобавитьСтроку(ТекстОшибок, ПрефиксОшибки + "Length Uom is empty!");
		КонецЕсли;
		
		Если ЗначениеЗаполнено(СтруктураParcel.WD) И НЕ ЗначениеЗаполнено(СтруктураParcel.WIDTHUOM) Тогда
			ДобавитьСтроку(ТекстОшибок, ПрефиксОшибки + "Width Uom is empty!");
		КонецЕсли;
		
		Если ЗначениеЗаполнено(СтруктураParcel.HT) И НЕ ЗначениеЗаполнено(СтруктураParcel.HTUOM) Тогда
			ДобавитьСтроку(ТекстОшибок, ПрефиксОшибки + "Height Uom is empty!");
		КонецЕсли;
		
		Если СтруктураParcel.LENUOM <> СтруктураParcel.WIDTHUOM
			ИЛИ СтруктураParcel.WIDTHUOM <> СтруктураParcel.HTUOM Тогда
			ДобавитьСтроку(ТекстОшибок, ПрефиксОшибки + "Length / Width / Height Uoms can not be different!");
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(СтруктураParcel.GROSSWGT) Тогда
			ДобавитьСтроку(ТекстОшибок, ПрефиксОшибки + "Gross Weight per Ship Unit is empty!");
		КонецЕсли;

		Если НЕ ЗначениеЗаполнено(СтруктураParcel.GROSSWGTUOM) Тогда
			ДобавитьСтроку(ТекстОшибок, ПрефиксОшибки + "Gross Weight Uom is empty!");
		КонецЕсли;
		
		Если СтруктураParcel.Items.Количество() = 0 Тогда
			ДобавитьСтроку(ТекстОшибок, ПрефиксОшибки + "at least one item required!");
			Продолжить;
		КонецЕсли;
		
		НомерItem = 0;
		Для Каждого СтруктураItem Из СтруктураParcel.Items Цикл
			
			НомерItem = НомерItem + 1;
			ПрефиксОшибки = "Ship. unit " + НомерParcel + ", Item " + НомерItem + ": "; 
			
			Если НЕ ЗначениеЗаполнено(СтруктураItem.PARTNUM) Тогда
				ДобавитьСтроку(ТекстОшибок, ПрефиксОшибки + "Item ID is empty!");
			КонецЕсли;
			
			Если НЕ ЗначениеЗаполнено(СтруктураItem.QTY) Тогда
				ДобавитьСтроку(ТекстОшибок, ПрефиксОшибки + "Quantity is empty!");
			КонецЕсли;
			
			Если НЕ ЗначениеЗаполнено(СтруктураItem.QTYUOM) Тогда
				ДобавитьСтроку(ТекстОшибок, ПрефиксОшибки + "Quantity Uom is empty!");
			КонецЕсли;
			
			Если ЗначениеЗаполнено(СтруктураItem.NETWGT) И НЕ ЗначениеЗаполнено(СтруктураItem.NETWGTUOM) Тогда
				ДобавитьСтроку(ТекстОшибок, ПрефиксОшибки + "Net weight Uom is empty!");
			КонецЕсли;
			
			Если НЕ ЗначениеЗаполнено(СтруктураItem.VALUE) Тогда
				ДобавитьСтроку(ТекстОшибок, ПрефиксОшибки + "Value is empty!");	
			КонецЕсли;
			
			Если НЕ ЗначениеЗаполнено(СтруктураItem.CURR) Тогда
				ДобавитьСтроку(ТекстОшибок, ПрефиксОшибки + "Currency is empty!");
			КонецЕсли;
					
		КонецЦикла;
		
	КонецЦикла;
	
	Возврат СокрЛП(ТекстОшибок);
	
КонецФункции


//////////////////////////////////////////////////////////////////////////////////////
// СОЗДАНИЕ ОБЪЕКТОВ БАЗЫ

// ДОДЕЛАТЬ
Функция СоздатьОбъекты(СтруктураПисьма) 
	
	ТекстОшибок = "";
	 	 			
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("SourceEmailUID", СтруктураПисьма.UID);
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ExportRequest.Ссылка,
		|	ExportRequest.AcceptedBySpecialist
		|ИЗ
		|	Документ.ExportRequest КАК ExportRequest
		|ГДЕ
		|	SourceEmailUID = &SourceEmailUID";
			
	Результат = Запрос.Выполнить();
	Если Результат.Пустой() ИЛИ Не РГСофтСерверПовтИспСеанс.ЭтоProductionБаза() Тогда
		
		ERОбъект = Документы.ExportRequest.СоздатьДокумент();
		ERОбъект.SourceEmailUID = СтруктураПисьма.UID;
		ERОбъект.Submitted = ТекущаяДата();
		
	Иначе
		
		Выборка = Результат.Выбрать();
		Выборка.Следующий();
		Если ЗначениеЗаполнено(Выборка.AcceptedBySpecialist) Тогда
			ВызватьИсключение "" + Выборка.Ссылка + " with UID '" + СтруктураПисьма.UID + "' was already accepted by Export specialist!";
		КонецЕсли;
		
		ERОбъект = Выборка.Ссылка.ПолучитьОбъект();
		
	КонецЕсли;
	
	ERОбъект.ДополнительныеСвойства.Вставить("LoadingFromEmail");
	
	// Submitter
	Submitter = Справочники.Пользователи.ПолучитьПоEmail(СтруктураПисьма.SubmitterEmail);
	Если НЕ ЗначениеЗаполнено(Submitter) Тогда
		Submitter = Справочники.Пользователи.СоздатьTrackerПоEmail(СтруктураПисьма.SubmitterEmail);	
	КонецЕсли;
	ERОбъект.Submitter = Submitter;
		
	// Дата
	ERОбъект.Дата = ТекущаяДата();
	
	// Comments
	ERОбъект.Comments = СтруктураПисьма.NOTES;
	
	// From country
	Если ЗначениеЗаполнено(СтруктураПисьма.COUNTRY) Тогда
		
		FromCountry = ImportExportСерверПовтИспСеанс.ПолучитьRCACountryПоTMSID(СтруктураПисьма.COUNTRY);
		Если ЗначениеЗаполнено(FromCountry) Тогда
			ERОбъект.FromCountry = FromCountry;	
		Иначе
			ДобавитьСтроку(ТекстОшибок, "Failed to find Source country by TMS ID """ + СтруктураПисьма.COUNTRY + """!");
		КонецЕсли;
		
	КонецЕсли;
		
	// Legal entity
	FromLegalEntity = ImportExportСерверПовтИспСеанс.ПолучитьLegalEntityПоРеквизитамTMS(
		СтруктураПисьма.LE,
		СтруктураПисьма.COUNTRY,
		СтруктураПисьма.ERPID,
		СтруктураПисьма.FINLOCCODE,
		СтруктураПисьма.FINPROCESS);
		
	// Legal entity, Company
	Если ЗначениеЗаполнено(FromLegalEntity) Тогда
		
		ERОбъект.FromLegalEntity = FromLegalEntity;
		
		ParentCompany = РГСофтСерверПовтИспСеанс.ПолучитьЗначениеРеквизита(FromLegalEntity, "ParentCompany");
		Если ЗначениеЗаполнено(ParentCompany) Тогда
			ERОбъект.Company = ParentCompany;
		Иначе
			ДобавитьСтроку(ERОбъект.Comments, "! Parent company is empty in Legal entity """ + FromLegalEntity + """!");
		КонецЕсли;
		
	Иначе
		ДобавитьСтроку(ERОбъект.Comments, "! Failed to find TMS Legal entity by Company code """ + СтруктураПисьма.LE + """, Country code """ + СтруктураПисьма.COUNTRY + """, ERP ID """ + СтруктураПисьма.ERPID + """, Finance loc code """ + СтруктураПисьма.FINLOCCODE + """ and Finance process """ + СтруктураПисьма.FINPROCESS + """!");	
	КонецЕсли;
	
	// AU
	Если ЗначениеЗаполнено(СтруктураПисьма.CC) Тогда
		
		//-> RG-Soft VIvanov 2015/02/18
		//AU = ImportExportСерверПовтИспСеанс.ПолучитьAUПоКоду(СтруктураПисьма.CC);	
		AU = РГСофт.НайтиAU(ERОбъект.Дата, СтруктураПисьма.CC);
		//<- RG-Soft VIvanov
		Если ЗначениеЗаполнено(AU) Тогда
			ERОбъект.AU = AU;
			ERОбъект.Segment = РГСофтСерверПовтИспСеанс.ПолучитьЗначениеРеквизита(AU, "Segment");
		Иначе
			ДобавитьСтроку(ERОбъект.Comments, "! Failed to find AU by code """ + СтруктураПисьма.CC + """!");			
		КонецЕсли;
		
	КонецЕсли;
	
	// Activity
	Если ЗначениеЗаполнено(СтруктураПисьма.AC) Тогда
		ERОбъект.Activity = СтруктураПисьма.AC;
	КонецЕсли;
	
	// External reference
	Если ЗначениеЗаполнено(СтруктураПисьма.EXTERNALID) Тогда
		ERОбъект.ExternalReference = СтруктураПисьма.EXTERNALID;
	КонецЕсли;
	
	// Job number
	Если ЗначениеЗаполнено(СтруктураПисьма.JOBNUM) Тогда
		ERОбъект.JobNumber = СтруктураПисьма.JOBNUM;	
	КонецЕсли;
	
	// Urgency, Urgency Comment
	Если ЗначениеЗаполнено(СтруктураПисьма.PRIORITY) Тогда
		
		Urgency = Перечисления.Urgencies.ПолучитьПоTMSName(СтруктураПисьма.PRIORITY);
		Если ЗначениеЗаполнено(Urgency) Тогда
			
			// Решили, что Emeregency надо понижать до Urgent
			Если Urgency = Перечисления.Urgencies.Emergency Тогда
				Urgency = Перечисления.Urgencies.Urgent;
			КонецЕсли;
			
			ERОбъект.Urgency = Urgency;
			
			Если Urgency = Перечисления.Urgencies.Urgent Тогда
				ERОбъект.UrgencyComment = СтруктураПисьма.PRIORITY;	
			КонецЕсли;
			
		Иначе
			ДобавитьСтроку(ERОбъект.Comments, "! Failed to find Urgency by TMS Name """ + СтруктураПисьма.PRIORITY + """!");
		КонецЕсли;
		
	КонецЕсли;
	
	// Required delivery date
	Если ЗначениеЗаполнено(СтруктураПисьма.DELIVERYDATE) Тогда
		
		// ЛУЧШЕ ПЛЕВАТЬСЯ И ПЕРЕХВАТЫВАТЬ ИСКЛЮЧЕНИЯ КАК ОБЫЧНО
		RequiredDeliveryDate = ПреобразоватьСтрокуВДату(СтруктураПисьма.DELIVERYDATE, ERОбъект.Comments, "DELIVERYDATE");
		Если ЗначениеЗаполнено(RequiredDeliveryDate) Тогда
			ERОбъект.RequiredDeliveryDate = RequiredDeliveryDate;
		КонецЕсли;
		
	КонецЕсли;
		
	// Ready to ship date
	Если ЗначениеЗаполнено(СтруктураПисьма.PICKUPDATE) Тогда
		
		// ЛУЧШЕ ПЛЕВАТЬСЯ И ПЕРЕХВАТЫВАТЬ ИСКЛЮЧЕНИЯ КАК ОБЫЧНО
		ReadyToShipDate = ПреобразоватьСтрокуВДату(СтруктураПисьма.PICKUPDATE, ERОбъект.Comments, "PICKUPDATE");
		Если ЗначениеЗаполнено(ReadyToShipDate) Тогда
			ERОбъект.ReadyToShipDate = ReadyToShipDate;
		КонецЕсли;
		
	КонецЕсли;
		
	// Shipper
	Если ЗначениеЗаполнено(СтруктураПисьма.Shipper) Тогда
		
		Shipper = ImportExportСерверПовтИспСеанс.ПолучитьConsignToПоTMSID(СтруктураПисьма.Shipper);
		Если ЗначениеЗаполнено(Shipper) Тогда
			ERОбъект.Shipper = Shipper;
		Иначе
			ДобавитьСтроку(ERОбъект.Comments, "! Failed to find Shipper by TMS ID """ + СтруктураПисьма.Shipper + """!");
		КонецЕсли;
		
	КонецЕсли;
	
	// Shipper contact
	Если ЗначениеЗаполнено(СтруктураПисьма.ShipperContact) Тогда
		
		ShipperContact = ImportExportСерверПовтИспСеанс.ПолучитьSLSRCAПоКоду(СтруктураПисьма.ShipperContact);
		Если ЗначениеЗаполнено(ShipperContact) Тогда
			ERОбъект.ShipperContact = ShipperContact;
		Иначе
			ДобавитьСтроку(ERОбъект.Comments, "! Failed to find Shipper contact by alias '" + СтруктураПисьма.ShipperContact + "'!");	
		КонецЕсли;
				
	КонецЕсли;
	
	// Pick up warehouse
	Если ЗначениеЗаполнено(СтруктураПисьма.SOURCE) Тогда
		
		ERОбъект.PickUpWarehouse = Справочники.Warehouses.НайтиСоздатьПоTMSID(СтруктураПисьма.SOURCE);
				
		//РеквизитыPickUpWarehouse = РГСофтСерверПовтИспСеанс.ЗначенияРеквизитовОбъекта(ERОбъект.PickUpWarehouse, "ContactName, ContactPhone, ContactEmail");
		//РГСофт.УстановитьЕслиЗаполнено(ERОбъект.PickUpFromContact, РеквизитыPickUpWarehouse.ContactName);
		//РГСофт.УстановитьЕслиЗаполнено(ERОбъект.PickUpFromPhone, РеквизитыPickUpWarehouse.ContactPhone); 		
		//РГСофт.УстановитьЕслиЗаполнено(ERОбъект.PickUpFromEmail, РеквизитыPickUpWarehouse.ContactEmail); 	
						
	КонецЕсли;
		
	// Consignee
	Если ЗначениеЗаполнено(СтруктураПисьма.Consignee) Тогда
		
		ERОбъект.Consignee = Справочники.Warehouses.НайтиСоздатьПоTMSID(СтруктураПисьма.Consignee); 
		
		РеквизитыConsignee = РГСофтСерверПовтИспСеанс.ЗначенияРеквизитовОбъекта(ERОбъект.Consignee, "ContactName, ContactPhone, ContactEmail");
		РГСофт.УстановитьЕслиЗаполнено(ERОбъект.ConsigneeContact, РеквизитыConsignee.ContactName);
		РГСофт.УстановитьЕслиЗаполнено(ERОбъект.ConsigneePhone, РеквизитыConsignee.ContactPhone); 		
		РГСофт.УстановитьЕслиЗаполнено(ERОбъект.ConsigneeEmail, РеквизитыConsignee.ContactEmail); 	
		
	КонецЕсли;
			
	// Deliver to
	Если ЗначениеЗаполнено(СтруктураПисьма.DEST) Тогда
		
		ERОбъект.DeliverTo = Справочники.Warehouses.НайтиСоздатьПоTMSID(СтруктураПисьма.DEST);
		
		//РеквизитыDeliverTo = РГСофтСерверПовтИспСеанс.ЗначенияРеквизитовОбъекта(ERОбъект.DeliverTo, "ContactName, ContactPhone, ContactEmail");
		//РГСофт.УстановитьЕслиЗаполнено(ERОбъект.DeliverToContact, РеквизитыDeliverTo.ContactName);
		//РГСофт.УстановитьЕслиЗаполнено(ERОбъект.DeliverToPhone, РеквизитыDeliverTo.ContactPhone); 		
		//РГСофт.УстановитьЕслиЗаполнено(ERОбъект.DeliverToEmail, РеквизитыDeliverTo.ContactEmail); 
		
	КонецЕсли;
	
	// POA
	Если ЗначениеЗаполнено(ERОбъект.DeliverTo) Тогда
		
		DeliverToCountryCode = РГСофтСерверПовтИспСеанс.ПолучитьЗначениеРеквизита(ERОбъект.DeliverTo, "CountryCode");
		POA = ImportExportСерверПовтИспСеанс.ПолучитьCountryHUBПоTMSID(DeliverToCountryCode);
		Если ЗначениеЗаполнено(POA) Тогда
			ERОбъект.POA = POA;
		Иначе
			ДобавитьСтроку(ERОбъект.Comments, "! Failed to find Country by code '" + DeliverToCountryCode + "' specified for deliver-to '" + ERОбъект.DeliverTo + "'!");	
		КонецЕсли;
		
	КонецЕсли;
					
	// Recharge
	ERОбъект.Recharge = СтруктураПисьма.RECHARGE_FLAG = "I";
	
	Если ERОбъект.Recharge Тогда
		
		// Recharge legal entity
		RechargeLegalEntity = ImportExportСерверПовтИспСеанс.ПолучитьLegalEntityПоРеквизитамTMS(
	 		СтруктураПисьма.RECHARGE_LE,
			СтруктураПисьма.RECHARGE_COUNTRY,
			СтруктураПисьма.RECHARGE_ERPID,
			СтруктураПисьма.RECHARGE_LOC_CODE,
			СтруктураПисьма.RECHARGE_FIN_PROCESS);
					
		Если ЗначениеЗаполнено(RechargeLegalEntity) Тогда	
			ERОбъект.RechargeToLegalEntity = RechargeLegalEntity;			
		Иначе
			ДобавитьСтроку(ERОбъект.Comments, "! Failed to find TMS Recharge legal entity by Company code """ + СтруктураПисьма.RECHARGE_LE + """, Country code """ + СтруктураПисьма.RECHARGE_COUNTRY + """, ERP ID """ + СтруктураПисьма.RECHARGE_ERPID + """, Finance loc code """ + СтруктураПисьма.RECHARGE_LOC_CODE + """ and Finance process """ + СтруктураПисьма.RECHARGE_FIN_PROCESS + """!");	
		КонецЕсли;
		
		// Recharge AU
		Если ЗначениеЗаполнено(СтруктураПисьма.RECHARGE_CC) Тогда
			ERОбъект.RechargeToAU = СтруктураПисьма.RECHARGE_CC;	
		КонецЕсли;
		
		// Recharge activity
		Если ЗначениеЗаполнено(СтруктураПисьма.RECHARGE_AC) Тогда
			ERОбъект.RechargeToActivity = СтруктураПисьма.RECHARGE_AC;	
		КонецЕсли;
		
	КонецЕсли;
	
	// Incoterms
	Если ЗначениеЗаполнено(СтруктураПисьма.INCOTERM) Тогда
		
		Incoterms = ImportExportСерверПовтИспСеанс.ПолучитьIncotermsПоКоду(СтруктураПисьма.INCOTERM);
		Если ЗначениеЗаполнено(Incoterms) Тогда
			ERОбъект.Incoterms = Incoterms;
		Иначе
			ДобавитьСтроку(ERОбъект.Comments, "! Failed to find Incoterms by code """ + СтруктураПисьма.INCOTERM + """!");
		КонецЕсли;
		
	КонецЕсли;
	
	// Paying Entity
	Если ЗначениеЗаполнено(СтруктураПисьма.PAYING_ENTITY_FLAG) Тогда
		
		PayingEntity = Перечисления.PayingEntities[СтруктураПисьма.PAYING_ENTITY_FLAG];
		Если ЗначениеЗаполнено(PayingEntity) Тогда
			ERОбъект.PayingEntity = PayingEntity;
		Иначе
			ДобавитьСтроку(ERОбъект.Comments, "! Failed to find Paying entity by code """ + СтруктураПисьма.PAYING_ENTITY_FLAG + """!");
		КонецЕсли;
		
	КонецЕсли;
	
	// Involved party locations и contacts
	ERОбъект.OtherInvolvedLocations.Очистить();
	ERОбъект.OtherInvolvedContacts.Очистить();	
	Для Каждого СтруктураInvolvedParty Из СтруктураПисьма.InvolvedParties Цикл
		
		Если ЗначениеЗаполнено(СтруктураInvolvedParty.INVOLVED_PARTY_LOCATION) Тогда
			
			НоваяСтрока = ERОбъект.OtherInvolvedLocations.Добавить();
			
			LocationQualifier = ImportExportСерверПовтИспСеанс.ПолучитьLocationQualifierПоКоду(СтруктураInvolvedParty.INVOLVED_PARTY_QUALIFIER);
			Если НЕ ЗначениеЗаполнено(LocationQualifier) Тогда
				ДобавитьСтроку(ERОбъект.Comments, "! Failed to find Location qualifier by code '" + СтруктураInvolvedParty.INVOLVED_PARTY_QUALIFIER + "'!");	
			Иначе
				НоваяСтрока.LocationQualifier = LocationQualifier;	
			КонецЕсли;			
			
			НоваяСтрока.LocationId = СтруктураInvolvedParty.INVOLVED_PARTY_LOCATION;
				
		Иначе
			
			НоваяСтрока = ERОбъект.OtherInvolvedContacts.Добавить();
			
			ContactQualifier = ImportExportСерверПовтИспСеанс.ПолучитьContactQualifierПоDomainAndQualifier(СтруктураInvolvedParty.INVOLVED_PARTY_QUALIFIER);
			Если НЕ ЗначениеЗаполнено(ContactQualifier) Тогда
				ДобавитьСтроку(ERОбъект.Comments, "! Failed to find Contact qualifier by code '" + СтруктураInvolvedParty.INVOLVED_PARTY_QUALIFIER + "'!");	
			Иначе
				НоваяСтрока.ContactQualifier = ContactQualifier;	
			КонецЕсли;
			
			НоваяСтрока.ContactId = СтруктураInvolvedParty.CONTACT_ID;
			
		КонецЕсли;
		
	КонецЦикла;
	
	// Если произошли критические ошибки - посылаем сообщение и уходим
	Если ЗначениеЗаполнено(ТекстОшибок) Тогда
		Возврат ТекстОшибок;
	КонецЕсли;
	
	// Source e-mail
	ERОбъект.SourceEMail = СтруктураПисьма.SourceEmail;
	
	ERОбъектНовый = ERОбъект.ЭтоНовый();
	
	ERОбъект.Записать();
	
	СоздатьItemsИParcels(СтруктураПисьма, ERОбъект.Ссылка, ERОбъектНовый);	
	
	Возврат ERОбъект;
	
КонецФункции

Процедура СоздатьItemsИParcels(СтруктураПисьма, ERСсылка, ERОбъектНовый)
	
	// Если Export request уже есть в базе - получим его парсели и товары, чтобы перезаполнить
	Если НЕ ERОбъектНовый Тогда
		
		Запрос = Новый Запрос;
		Запрос.УстановитьПараметр("ExportRequest", ERСсылка);
		Запрос.Текст = 
			"ВЫБРАТЬ
			|	Parcels.Ссылка
			|ИЗ
			|	Справочник.Parcels КАК Parcels
			|ГДЕ
			|	Parcels.ExportRequest = &ExportRequest
			|	И НЕ Parcels.Отменен
			|
			|УПОРЯДОЧИТЬ ПО
			|	Parcels.Код";
		ВыборкаParcels = Запрос.Выполнить().Выбрать();
		
	КонецЕсли;
	
	Для Каждого СтруктураParcel из СтруктураПисьма.Parcels Цикл
		
		Если НЕ ERОбъектНовый И ВыборкаParcels.Следующий() Тогда
			ParcelОбъект = ВыборкаParcels.Ссылка.ПолучитьОбъект();
			ParcelОбъект.Comment = "";
		Иначе
			ParcelОбъект = Справочники.Parcels.СоздатьЭлемент();	
		КонецЕсли;
		
		ParcelОбъект.ExportRequest = ERСсылка;
		
		СоздатьItemsИЗаполнитьДеталиParcel(СтруктураParcel, ParcelОбъект);
		
		// Packing type
		Если ЗначениеЗаполнено(СтруктураParcel.UOM) Тогда
			
			PackingType = ImportExportСерверПовтИспСеанс.ПолучитьPackingTypeПоTMSID(СтруктураParcel.UOM);
			
			Если ЗначениеЗаполнено(PackingType) Тогда
				ParcelОбъект.PackingType = PackingType;
			Иначе
				ДобавитьСтроку(ParcelОбъект.Comment, "! Failed to find Packing type by TMS ID '" + СтруктураParcel.UOM + "'!");	
			КонецЕсли;
			
		КонецЕсли;
		
		// Serial no.
		Если ЗначениеЗаполнено(СтруктураParcel.PACKAGE_SERIAL_NO) Тогда
			ParcelОбъект.SerialNo = СтруктураParcel.PACKAGE_SERIAL_NO;
		КонецЕсли;
		
		// Num Of Parcels
		Если ЗначениеЗаполнено(СтруктураParcel.QTY) Тогда
			
			NumOfParcels = ПреобразоватьСтрокуВЧисло(СтруктураParcel.QTY, ParcelОбъект.Comment, "Num. of parcels");
			Если ЗначениеЗаполнено(NumOfParcels) Тогда
				ParcelОбъект.NumOfParcels = NumOfParcels;
			КонецЕсли;	
			
		КонецЕсли;

		// Length
		Если ЗначениеЗаполнено(СтруктураParcel.LEN) Тогда
			
			Length = ПреобразоватьСтрокуВЧисло(СтруктураParcel.LEN, ParcelОбъект.Comment, "Length");
			Если ЗначениеЗаполнено(Length) Тогда
				ParcelОбъект.Length = Length;
			КонецЕсли;
			
		КонецЕсли;

		// Width
		Если ЗначениеЗаполнено(СтруктураParcel.WD) Тогда
			
			Width = ПреобразоватьСтрокуВЧисло(СтруктураParcel.WD, ParcelОбъект.Comment, "Width");
			Если ЗначениеЗаполнено(Width) Тогда
				ParcelОбъект.Width = Width;
			КонецЕсли;
			
		КонецЕсли;
		
		// Height
		Если ЗначениеЗаполнено(СтруктураParcel.HT) Тогда
			
			Height = ПреобразоватьСтрокуВЧисло(СтруктураParcel.HT, ParcelОбъект.Comment, "Height");
			Если ЗначениеЗаполнено(Height) Тогда
				ParcelОбъект.Height = Height;
			КонецЕсли;
			
		КонецЕсли;
		
		// DIMs UOM
		Если ЗначениеЗаполнено(СтруктураParcel.LENUOM) Тогда
			
			DIMsUOM = ImportExportСерверПовтИспСеанс.ПолучитьUOMПоTMSID(СтруктураParcel.LENUOM);
			Если ЗначениеЗаполнено(DIMsUOM) Тогда 
				ParcelОбъект.DIMsUOM = DIMsUOM;
            Иначе
				ДобавитьСтроку(ParcelОбъект.Comment, "! Failed to find DIMs UOM by TMS Id """ + СтруктураParcel.LENUOM + """!");
			КонецЕсли;
                						
		КонецЕсли;           
		
		// Total gross weight
		Если ЗначениеЗаполнено(СтруктураParcel.GROSSWGT) Тогда
			
			GrossWeightPerParcel = ПреобразоватьСтрокуВЧисло(СтруктураParcel.GROSSWGT, ParcelОбъект.Comment, "Total gross weight");
			Если ЗначениеЗаполнено(GrossWeightPerParcel) Тогда
				ParcelОбъект.GrossWeight = GrossWeightPerParcel * ParcelОбъект.NumOfParcels;
			КонецЕсли;
			
		КонецЕсли;
		
		// Weight UOM
		Если ЗначениеЗаполнено(СтруктураParcel.GROSSWGTUOM) Тогда
			
			WeightUOM = ImportExportСерверПовтИспСеанс.ПолучитьUOMПоTMSID(СтруктураParcel.GROSSWGTUOM);
			Если ЗначениеЗаполнено(WeightUOM) Тогда
				
				GrossKG = ПолучитьВKG(ParcelОбъект.GrossWeight, WeightUOM);
				Если GrossKG <> Неопределено Тогда
					
					ParcelОбъект.GrossWeight = GrossKG;
					ParcelОбъект.WeightUOM = Справочники.UOMs.KG;
					
				Иначе
					
					ДобавитьСтроку(ParcelОбъект.Comment, "! Failed to convert '" + СтруктураParcel.GROSSWGTUOM + "' to 'KG'!");	
					
				КонецЕсли;
								
			Иначе 
				ДобавитьСтроку(ParcelОбъект.Comment, "! Failed to find Weight UOM by TMS Id """ + СтруктураParcel.GROSSWGTUOM + """!");
			КонецЕсли; 
			
		КонецЕсли;

		// Total net weight
		ParcelОбъект.NetWeight = ParcelОбъект.Детали.Итог("NetWeight");

		ParcelОбъект.Записать();  
				
	КонецЦикла;
	
	// Удалим оставшиеся существующие парсели
	Если НЕ ERОбъектНовый Тогда
		
		Пока ВыборкаParcels.Следующий() Цикл
			
			ВыборкаParcels.Ссылка.ПолучитьОбъект().УстановитьПометкуУдаления(Ложь);
			
		КонецЦикла;
		
	КонецЕсли;
	
КонецПроцедуры

Процедура СоздатьItemsИЗаполнитьДеталиParcel(СтруктураParcel, ParcelОбъект)
	
	// В TMS косяк из-за которого ERP treatment находится на уровне парселя, а не товара
	ERPTreatment = Неопределено;
	Если ЗначениеЗаполнено(СтруктураParcel.ITEMTYPE) Тогда
		
		ERPTreatment = Перечисления.ТипыЗаказа.ПолучитьПоTMSId(СтруктураParcel.ITEMTYPE);
		Если НЕ ЗначениеЗаполнено(ERPTreatment) Тогда
			ДобавитьСтроку(ParcelОбъект.Comment, "! Failed to find ERP treatment """ + СтруктураParcel.ITEMTYPE + """!");	
		КонецЕсли;
		
	КонецЕсли;
	
	ТЧДетали = ParcelОбъект.Детали;
	
	НомерItem = 1;
	Для Каждого СтруктураItem из СтруктураParcel.Items Цикл
		
		ItemComment = "";
		
		// Если товар уже есть в табличной части - перезаполним его
		// Иначе - создадим новый товар
		Если НомерItem <= ТЧДетали.Количество() И ЗначениеЗаполнено(ТЧДетали[НомерItem-1].СтрокаИнвойса) Тогда
			ItemОбъект = ТЧДетали[НомерItem-1].СтрокаИнвойса.ПолучитьОбъект();		
		Иначе
			ItemОбъект = Справочники.СтрокиИнвойса.СоздатьЭлемент();	
		КонецЕсли;	
		
		// Export request
		ItemОбъект.ExportRequest = ParcelОбъект.ExportRequest;
		
		Если ЗначениеЗаполнено(СтруктураItem.PARTNUM) Тогда
			ItemОбъект.КодПоИнвойсу = СтруктураItem.PARTNUM;
		КонецЕсли;
		
		// Item description
		//ItemDescription = Неопределено;
		//Попытка
		ItemDescription = Обработки.PullMasterDataFromTMS.ПолучитьРеквизитыItem(СтруктураItem.PARTNUM).Description;
		//Исключение
		//	ДобавитьСтроку(ItemComment, "! Failed to get Description by Part no.""" + СтруктураItem.PARTNUM + """ from TMS!");	
		//КонецПопытки;
		
		Если ЗначениеЗаполнено(ItemDescription) Тогда
        	ItemОбъект.НаименованиеТовара = ItemDescription;
		КонецЕсли;
		
		// Serial no.
		Если ЗначениеЗаполнено(СтруктураItem.SERIAL_NO) Тогда
			ItemОбъект.СерийныйНомер = СтруктураItem.SERIAL_NO;
		КонецЕсли;
		
		// RAN
		Если ЗначениеЗаполнено(СтруктураItem.RAN) Тогда
			ItemОбъект.RAN = СтруктураItem.RAN;
		КонецЕсли;
		
		// Import reference
		Если ЗначениеЗаполнено(СтруктураItem.LICNO) Тогда
			ItemОбъект.ImportReference = СтруктураItem.LICNO;
		КонецЕсли;
		
		// Country of origin
		Если ЗначениеЗаполнено(СтруктураItem.COO) Тогда
			
			COO = ImportExportСерверПовтИспСеанс.ПолучитьCountryHUBПоTMSID(СтруктураItem.COO);
			Если НЕ ЗначениеЗаполнено(COO) Тогда
				ДобавитьСтроку(ItemComment, "! Failed to find COO by TMS Id '" + СтруктураItem.COO + "'!");	
			Иначе
				ItemОбъект.СтранаПроисхождения = COO;	
			КонецЕсли;
			
		КонецЕсли;
		
		// ERP treatment
		Если ЗначениеЗаполнено(ERPTreatment) Тогда
			ItemОбъект.Классификатор = ERPTreatment;	
		КонецЕсли;
		
		// UOM	
		Если ЗначениеЗаполнено(СтруктураItem.QTYUOM) Тогда
			
			QtyUOM = ImportExportСерверПовтИспСеанс.ПолучитьUOMПоTMSIDForItemUOM(СтруктураItem.QTYUOM);
			Если ЗначениеЗаполнено(QtyUOM) Тогда 
				ItemОбъект.ЕдиницаИзмерения = QtyUOM;
	        Иначе
				ДобавитьСтроку(ItemComment, "! Failed to find UOM by TMS Id for Item UOM '" + СтруктураItem.QTYUOM + "'!");
			КонецЕсли;
			
		КонецЕсли;
      		
		// Currency
		Если ЗначениеЗаполнено(СтруктураItem.CURR) Тогда
			
			Currency = ImportExportСерверПовтИспСеанс.ПолучитьCurrencyПоНаименованиюEng(СтруктураItem.CURR);
			Если ЗначениеЗаполнено(Currency) Тогда 
				ItemОбъект.Currency = Currency;
			Иначе		
				ДобавитьСтроку(ItemComment, "! Failed to find Currency by TMS Id """ + СтруктураItem.CURR + """!");
			КонецЕсли;
			
		КонецЕсли;
		
		// QTY	
		Если ЗначениеЗаполнено(СтруктураItem.QTY) Тогда
			
			QTY = ПреобразоватьСтрокуВЧисло(СтруктураItem.QTY, ItemComment, "QTY");
			Если ЗначениеЗаполнено(QTY) Тогда
				ItemОбъект.Количество = QTY;
			КонецЕсли;
			
		КонецЕсли;
			
		// Total price
		Если ЗначениеЗаполнено(СтруктураItem.Value) Тогда
			
			TotalPrice = ПреобразоватьСтрокуВЧисло(СтруктураItem.Value, ItemComment, "Total price");
			Если ЗначениеЗаполнено(TotalPrice) Тогда
				ItemОбъект.Сумма = TotalPrice;
			КонецЕсли;
			
		КонецЕсли;
		
		// Unit Price
		ItemОбъект.Цена = ?(ItemОбъект.Количество = 0, 0, ItemОбъект.Сумма/ItemОбъект.Количество);
		
		// Net weight
		Если ЗначениеЗаполнено(СтруктураItem.NETWGT) Тогда
			
			NetWeight = ПреобразоватьСтрокуВЧисло(СтруктураItem.NETWGT, ItemComment, "Net weight");
			Если ЗначениеЗаполнено(NetWeight) Тогда
				ItemОбъект.NetWeight = NetWeight;
			КонецЕсли;
			
		КонецЕсли;

		// Weight UOM
		Если ЗначениеЗаполнено(СтруктураItem.NETWGTUOM) Тогда
			
			WeightUOM = ImportExportСерверПовтИспСеанс.ПолучитьUOMПоTMSID(СтруктураItem.NETWGTUOM);
			Если ЗначениеЗаполнено(WeightUOM) Тогда
				
				NetKG = ПолучитьВKG(ItemОбъект.NetWeight, WeightUOM);
				Если NetKG <> Неопределено Тогда
					
					ItemОбъект.NetWeight = NetKG;
					ItemОбъект.WeightUOM = Справочники.UOMs.KG;
					
				Иначе
					
					ДобавитьСтроку(ItemComment, "! Failed to convert '" + СтруктураItem.NETWGTUOM + "' to 'KG'!");	
					
				КонецЕсли;		
				
			Иначе
				ДобавитьСтроку(ItemComment, "! Failed to find Weight UOM by TMS Id '" + СтруктураItem.NETWGTUOM + "'!");
			КонецЕсли;
			
		КонецЕсли;
		
		// PO no.
		Если ЗначениеЗаполнено(СтруктураItem.PONUM) Тогда
			ItemОбъект.НомерЗаявкиНаЗакупку = СтруктураItem.PONUM;
		КонецЕсли;
		
		// PO line
		Если ЗначениеЗаполнено(СтруктураItem.PONUM) И ЗначениеЗаполнено(СтруктураItem.PO_LINE) Тогда
			
			POLineNo = Неопределено;
			Попытка
				POLineNo = Число(СтруктураItem.PO_LINE);
			Исключение
				ДобавитьСтроку(ItemComment, "! Failed to convert '" + СтруктураItem.PO_LINE + "' to PO line number!");		
			КонецПопытки;
			
			Если ЗначениеЗаполнено(POLineNo) Тогда
				
				ItemОбъект.СтрокаЗаявкиНаЗакупку = Справочники.СтрокиЗаявкиНаЗакупку.ПолучитьPOLineПоPOnoИPOLineNo(СтруктураItem.PONUM, POLineNo); 
				Если НЕ ЗначениеЗаполнено(ItemОбъект.СтрокаЗаявкиНаЗакупку) Тогда
					ДобавитьСтроку(ItemComment, "! Failed to find PO line by PO no '" + СтруктураItem.PONUM + "' and PO line no. '" + POLineNo + "'!");	
				КонецЕсли;
				
			КонецЕсли;
			
		КонецЕсли;
		
		ItemОбъект.Записать();
			
		Если Не ПустаяСтрока(ItemComment) Тогда 
			ДобавитьСтроку(ParcelОбъект.Comment, "In Item " + НомерItem + ": " + ItemComment);
		КонецЕсли;
	
		//заполняем новую строку в табличной части Детали Parcel
		Если НомерItem <= ParcelОбъект.Детали.Количество() Тогда
			СтрокаДеталей = ТЧДетали[НомерItem-1];
		Иначе
			СтрокаДеталей = ТЧДетали.Добавить();
			СтрокаДеталей.СтрокаИнвойса = ItemОбъект.Ссылка;
		КонецЕсли;
				
		СтрокаДеталей.СерийныйНомер = ItemОбъект.СерийныйНомер;
		СтрокаДеталей.Receiver = ItemОбъект.ImportReference;
		СтрокаДеталей.Qty = ItemОбъект.Количество;
		СтрокаДеталей.QtyUOM = ItemОбъект.ЕдиницаИзмерения;
		СтрокаДеталей.NetWeight = ItemОбъект.NetWeight;
		
		НомерItem = НомерItem + 1;
		
	КонецЦикла;
	
	// Удалим оставшиеся существующие строки
	Пока НомерItem <= ТЧДетали.Количество() Цикл
		
		Item = ТЧДетали[НомерItem-1].СтрокаИнвойса;
		Если ЗначениеЗаполнено(Item) Тогда
			Item.ПолучитьОбъект().УстановитьПометкуУдаления(Истина);	
		КонецЕсли;
		
		ТЧДетали.Удалить(НомерItem-1);
		
	КонецЦикла;
	
КонецПроцедуры

Функция ПолучитьВKG(Weight, WeightUOM)
	
	Если НЕ ЗначениеЗаполнено(WeightUOM) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	KG = Справочники.UOMs.KG;
	
	Если WeightUOM = KG Тогда
		Возврат Weight;	
	КонецЕсли;
	
	WeightUOMDetails = РГСофтСерверПовтИспСеанс.ЗначенияРеквизитовОбъекта(WeightUOM, "StandardUOM, ConversionFactor");
	Если WeightUOMDetails.StandardUOM <> KG Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат Weight * WeightUOMDetails.ConversionFactor;
					
КонецФункции


//////////////////////////////////////////////////////////////////
// ОБЩИЕ ПРОЦЕДУРЫ / ФУНКЦИИ

Функция ПослатьПисьмоОбОшибке(ДанныеДляОтправкиОтвета, Причина)
	
	Тема = "Failed to process " + ДанныеДляОтправкиОтвета.ТемаИсходногоПисьма;
	
	Тело =
		"Failed to process " + ДанныеДляОтправкиОтвета.ТемаИсходногоПисьма + ".
		|" + Причина + ".
		|Please use Excel offline request form to submit new export request to RCA Import / Export Tracking system.";	
		
	// { RGS VChaplygin 15.04.2016 8:42:22 - Добавим аварийный почтовый аккаунт
	//ImportExportСервер.ПослатьПисьмо(
	//	ДанныеДляОтправкиОтвета.ИнтернетПочта,
	//	ДанныеДляОтправкиОтвета.АдресОтправителя,
	//	ДанныеДляОтправкиОтвета.АдресПолучателя,
	//	Тема,
	//	Тело, , , "riet-support@slb.com");
	Попытка
		ImportExportСервер.ПослатьПисьмо(
			ДанныеДляОтправкиОтвета.ИнтернетПочта,
			ДанныеДляОтправкиОтвета.АдресОтправителя,
			ДанныеДляОтправкиОтвета.АдресПолучателя,
			Тема,
			Тело, , , "riet-support@slb.com");
	Исключение
		
		ImportExportСервер.ПослатьПисьмо(
			ДанныеДляОтправкиОтвета.ИнтернетПочтаRCA,
			ДанныеДляОтправкиОтвета.АдресОтправителя,
			ДанныеДляОтправкиОтвета.АдресПолучателя,
			Тема,
			Тело, , , "riet-support@slb.com");
		
	КонецПопытки;		
	// { RGS VChaplygin 15.04.2016 8:42:22 - Добавим аварийный почтовый аккаунт
			
КонецФункции

// ДОДЕЛАТЬ
Функция ПослатьПисьмоОбУспехе(ДанныеДляОтправкиОтвета, ExportRequestNo)
	
	Тема = "Successfully loaded " + ДанныеДляОтправкиОтвета.ТемаИсходногоПисьма;
	
	Тело =
		"Successfully loaded " + ДанныеДляОтправкиОтвета.ТемаИсходногоПисьма + ".
		|Export request no.: " + ExportRequestNo + "
		|Please use RCA Import / Export Tracking system to track statuses of the Export request:
		|http://ru0149app35.dir.slb.com/RIET";
	// СДЕЛАТЬ ССЫЛКУ
		
	// { RGS VChaplygin 15.04.2016 8:42:22 - Добавим аварийный почтовый аккаунт
	//ImportExportСервер.ПослатьПисьмо(
	//	ДанныеДляОтправкиОтвета.ИнтернетПочта,
	//	ДанныеДляОтправкиОтвета.АдресОтправителя,
	//	ДанныеДляОтправкиОтвета.АдресПолучателя,
	//	Тема,
	//	Тело, , , "riet-support@slb.com");
	Попытка
		ImportExportСервер.ПослатьПисьмо(
			ДанныеДляОтправкиОтвета.ИнтернетПочта,
			ДанныеДляОтправкиОтвета.АдресОтправителя,
			ДанныеДляОтправкиОтвета.АдресПолучателя,
			Тема,
			Тело, , , "riet-support@slb.com");
	Исключение
		
		ImportExportСервер.ПослатьПисьмо(
			ДанныеДляОтправкиОтвета.ИнтернетПочтаRCA,
			ДанныеДляОтправкиОтвета.АдресОтправителя,
			ДанныеДляОтправкиОтвета.АдресПолучателя,
			Тема,
			Тело, , , "riet-support@slb.com");
		
	КонецПопытки;		
	// { RGS VChaplygin 15.04.2016 8:42:22 - Добавим аварийный почтовый аккаунт
			
КонецФункции

Функция ПреобразоватьСтрокуВДату(Знач стрЗначение, Comments, ИмяПоля)
	
	Если НЕ ЗначениеЗаполнено(стрЗначение) Тогда 
		Возврат Неопределено;
	КонецЕсли;
	
	День = Лев(стрЗначение, 2);
	
	Месяц = Сред(стрЗначение, 4, 3);
	Если Месяц = "JAN" Тогда 
		Месяц = "01";
	ИначеЕсли Месяц = "FEB" Тогда
		Месяц = "02";
	ИначеЕсли Месяц = "MAR" Тогда
		Месяц = "03";
	ИначеЕсли Месяц = "APR" Тогда
		Месяц = "04";
	ИначеЕсли Месяц = "MAY" Тогда
		Месяц = "05";
	ИначеЕсли Месяц = "JUN" Тогда
		Месяц = "06";
	ИначеЕсли Месяц = "JUL" Тогда
		Месяц = "07";
	ИначеЕсли Месяц = "AUG" Тогда
		Месяц = "08";
	ИначеЕсли Месяц = "SEP" Тогда
		Месяц = "09";
	ИначеЕсли Месяц = "OCT" Тогда
		Месяц = "10";
	ИначеЕсли Месяц = "NOV" Тогда
		Месяц = "11";
	ИначеЕсли Месяц = "DEC" Тогда
		Месяц = "12";
	КонецЕсли;
	
	Год = Сред(стрЗначение, 8, 4);
		  	
	Попытка
		Значение = Дата(Год+Месяц+День);
		Возврат Значение;
	Исключение
		ДобавитьСтроку(Comments, "! Failed to convert """ + стрЗначение + """ to """ + ИмяПоля + """!");
	КонецПопытки;
	
	Возврат Неопределено;
		
КонецФункции

Функция ПреобразоватьСтрокуВЧисло(Знач стрЗначение, Comments, ИмяПоля)
	
	Если НЕ ЗначениеЗаполнено(стрЗначение) Тогда 
		Возврат Неопределено;
	КонецЕсли;
	
	Попытка
		Значение = Число(стрЗначение);
		Возврат Значение;
	Исключение
		ДобавитьСтроку(Comments, "! Failed to convert """ + стрЗначение + """ to """ + ИмяПоля + """!");    
	КонецПопытки;
	
	Возврат Неопределено;
	
КонецФункции

Процедура ДобавитьСтроку(ИсходнаяСтрока, НоваяСтрока)
	
	ИсходнаяСтрока = ИсходнаяСтрока + Символы.ПС + НоваяСтрока;
			  
КонецПроцедуры
