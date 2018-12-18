
//////////////////////////////////////////////////////////////////////////////
// ФОРМА

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	//ТочноеВремяНачала = ОценкаПроизводительностиРГСофт.ТочноеВремя();
	
	ЗаполнитьCustomsPaymentUnallocatedSumИCustomsDocumentPaymentKindUnpaidSum();
		
	Если НЕ ЗначениеЗаполнено(Объект.CustomsPayment) Тогда
		ТекущийЭлемент = Элементы.CustomsPayment;
	ИначеЕсли НЕ ЗначениеЗаполнено(Объект.CustomsDocument) Тогда
		ТекущийЭлемент = Элементы.CustomsDocument;
	ИначеЕсли НЕ ЗначениеЗаполнено(Объект.Sum) Тогда
		ТекущийЭлемент = Элементы.Sum;
	Иначе
		ТекущийЭлемент = Элементы.Comment;
	КонецЕсли;
	
	//ОценкаПроизводительностиРГСофт.ЗафиксироватьВремяОкончания(ТочноеВремяНачала, Справочники.КлючевыеОперации.PaymentAllocationОткрытие, Объект.Ссылка);
	
КонецПроцедуры  


//////////////////////////////////////////////////////////////////////////////

&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
		
	//Если ПараметрыЗаписи.РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда
	//	ПараметрыЗаписи.Вставить("ТочноеВремяНачала", ОценкаПроизводительностиРГСофт.ТочноеВремя());
	//КонецЕсли;
	
	ТекущийОбъект.LastModified = ТекущаяДата();
	ОбщегоНазначения.УстановитьЗначение(ТекущийОбъект.Responsible, ПараметрыСеанса.ТекущийПользователь);
	
КонецПроцедуры


//////////////////////////////////////////////////////////////////////////////

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)
	
	ЗаполнитьCustomsPaymentUnallocatedSumИCustomsDocumentPaymentKindUnpaidSum();
	
	//Если ПараметрыЗаписи.РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда
	//	ОценкаПроизводительностиРГСофт.ЗафиксироватьВремяОкончания(ПараметрыЗаписи.ТочноеВремяНачала, Справочники.КлючевыеОперации.PaymentAllocationИнтерактивноеПроведение, Объект.Ссылка);
	//КонецЕсли;
	
КонецПроцедуры


//////////////////////////////////////////////////////////////////////////////

&НаКлиенте
Процедура ПослеЗаписи(ПараметрыЗаписи)
		
	СтруктураПараметров = Новый Структура;
	СтруктураПараметров.Вставить("CustomsPayment", Объект.CustomsPayment);
	СтруктураПараметров.Вставить("CustomsDocument", Объект.CustomsDocument);
	Оповестить("ИзмененДокументCustomsPaymentAllocation", СтруктураПараметров);
	
КонецПроцедуры


//////////////////////////////////////////////////////////////////////////////
// ШАПКА

// CUSTOMS PAYMENT

&НаКлиенте
Процедура CustomsPaymentНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;	
	
	СтруктураНастройки = Новый Структура;
	СтруктураНастройки.Вставить("Имя", "ВыборИзCustomsPaymentAllocation");
	СтруктураНастройки.Вставить("CustomsDocument", Объект.CustomsDocument);
	СтруктураНастройки.Вставить("PaymentKind", Объект.PaymentKind);
	СтруктураНастройки.Вставить("CurrentCustomsPayment", Объект.CustomsPayment);
		
	СтруктураПараметров = Новый Структура("СтруктураНастройки", СтруктураНастройки);
	ОткрытьФорму("Документ.CustomsPayment.ФормаВыбора", СтруктураПараметров, Элемент);
	
КонецПроцедуры

&НаКлиенте
Процедура CustomsPaymentПриИзменении(Элемент)
	
	Если ЗначениеЗаполнено(Объект.CustomsPayment) Тогда
		
		СтруктураДанных = ПолучитьСтруктуруДанныхПриИзмененииCustomsPayment(Объект.CustomsPayment, Объект.CustomsDocument, Объект.PaymentKind);
		CustomsPaymentUnallocatedSum = СтруктураДанных.CustomsPaymentUnallocatedSum;
		Если Объект.PaymentKind <> СтруктураДанных.PaymentKind Тогда
			Объект.PaymentKind = СтруктураДанных.PaymentKind;
			CustomsDocumentPaymentKindUnpaidSum = СтруктураДанных.CustomsDocumentPaymentKindUnpaidSum;
		КонецЕсли;
		
	Иначе
		CustomsPaymentUnallocatedSum = 0;
	КонецЕсли;
			
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьСтруктуруДанныхПриИзмененииCustomsPayment(CustomsPayment, CustomsDocument, PaymentKind)
	
	СтруктураВозврата = Новый Структура;
	СтруктураВозврата.Вставить("PaymentKind", PaymentKind);
	СтруктураВозврата.Вставить("CustomsPaymentUnallocatedSum", 0);
	
	// Получим несаллокированный остаток и Payment kind
	Если ЗначениеЗаполнено(CustomsPayment) Тогда
		
		СтруктураТекстов = Новый Структура;
		СтруктураПараметров = Новый Структура;
		
		СтруктураПараметров.Вставить("CustomsPayment", CustomsPayment);
		
		СтруктураТекстов.Вставить("CustomsPaymentUnallocatedSum",
			CustomsСервер.ПолучитьТекстЗапросаCustomsPaymentUnallocatedSum());
			
		СтруктураТекстов.Вставить("РеквизитыCustomsPayment",
			"ВЫБРАТЬ
			|	CustomsPayment.PaymentKind
			|ИЗ
			|	Документ.CustomsPayment КАК CustomsPayment
			|ГДЕ
			|	CustomsPayment.Ссылка = &CustomsPayment");
			
		СтруктураРезультатов = РГСофт.ПолучитьСтруктуруРезультатовТекстовЗапросов(СтруктураТекстов, СтруктураПараметров);
		
		Выборка = СтруктураРезультатов.CustomsPaymentUnallocatedSum.Выбрать();
		Если Выборка.Следующий()
			И ЗначениеЗаполнено(Выборка.SumОстаток) Тогда
			СтруктураВозврата.CustomsPaymentUnallocatedSum = Выборка.SumОстаток;
		КонецЕсли;
		
		Выборка = СтруктураРезультатов.РеквизитыCustomsPayment.Выбрать();
		Выборка.Следующий();
		Если ЗначениеЗаполнено(Выборка.PaymentKind) Тогда
			СтруктураВозврата.PaymentKind = Выборка.PaymentKind;
		КонецЕсли;
		
	КонецЕсли;
	
	Если ЗначениеЗаполнено(CustomsDocument)
		И PaymentKind <> СтруктураВозврата.PaymentKind Тогда
		
		CustomsDocumentPaymentKindUnpaidSum = ПолучитьCustomsDocumentPaymentKindUnpaidSum(CustomsDocument, СтруктураВозврата.PaymentKind);
		СтруктураВозврата.Вставить("CustomsDocumentPaymentKindUnpaidSum", CustomsDocumentPaymentKindUnpaidSum);		
		
	КонецЕсли;
	
	Возврат СтруктураВозврата;
	
КонецФункции

// CUSTOM DOCUMENT

&НаКлиенте
Процедура CustomsDocumentНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
		
	СтандартнаяОбработка = Ложь;
	
	СписокТипов = Новый СписокЗначений;
	СписокТипов.Добавить(Тип("ДокументСсылка.ГТД"), "ГТД");
	СписокТипов.Добавить(Тип("ДокументСсылка.CustomsFilesLight"), "ТПО");
		
	ЗначениеВыбора = ВыбратьИзСписка(СписокТипов, Элемент);
	Если ЗначениеВыбора <> Неопределено Тогда
		
		СтруктураНастройки = Новый Структура;
		СтруктураНастройки.Вставить("Имя", "ВыборИзCustomsPaymentAllocation");
		СтруктураНастройки.Вставить("CustomsPayment", Объект.CustomsPayment);
		СтруктураНастройки.Вставить("CurrentCustomsDocument", Объект.CustomsDocument);
		СтруктураПараметров = Новый Структура("СтруктураНастройки", СтруктураНастройки);
		
		Если ЗначениеВыбора.Значение = Тип("ДокументСсылка.ГТД") Тогда
			
			ОткрытьФорму("Документ.ГТД.ФормаВыбора", СтруктураПараметров, Элемент);
			
		ИначеЕсли ЗначениеВыбора.Значение = Тип("ДокументСсылка.CustomsFilesLight") Тогда 
			
			ОткрытьФорму("Документ.CustomsFilesLight.ФормаВыбора", СтруктураПараметров, Элемент);
						
		КонецЕсли; 
		
	КонецЕсли;
					
КонецПроцедуры  

&НаКлиенте
Процедура CustomsDocumentПриИзменении(Элемент)
	
	ПриИзмененииCustomsDocumentИлиPaymentKind();
		
КонецПроцедуры

&НаКлиенте
Процедура PaymentKindПриИзменении(Элемент)
	
	ПриИзмененииCustomsDocumentИлиPaymentKind();
	
КонецПроцедуры

&НаКлиенте
Процедура ПриИзмененииCustomsDocumentИлиPaymentKind()
	
	CustomsDocumentPaymentKindUnpaidSum = 0;
	Если ЗначениеЗаполнено(Объект.CustomsDocument) И ЗначениеЗаполнено(Объект.PaymentKind) Тогда
		CustomsDocumentPaymentKindUnpaidSum = ПолучитьCustomsDocumentPaymentKindUnpaidSum(Объект.CustomsDocument, Объект.PaymentKind);
	КонецЕсли; 
		
	Если НЕ ЗначениеЗаполнено(Объект.Sum) Тогда
		Объект.Sum = Мин(CustomsPaymentUnallocatedSum, CustomsDocumentPaymentKindUnpaidSum);
	КонецЕсли;
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьCustomsDocumentPaymentKindUnpaidSum(CustomsDocument, PaymentKind)
	
	CustomsDocumentPaymentKindUnpaidSum = 0;
	
	Если ЗначениеЗаполнено(CustomsDocument)
		И ЗначениеЗаполнено(PaymentKind) Тогда
		
		Запрос = Новый Запрос;
		Запрос.УстановитьПараметр("PaymentKind", PaymentKind);
		
		ТипЗнчCustomsDocument = ТипЗнч(CustomsDocument);
		Если ТипЗнчCustomsDocument = Тип("ДокументСсылка.ГТД") Тогда
			Запрос.УстановитьПараметр("CCD", CustomsDocument);
			Запрос.Текст = ПолучитьТекстЗапросаCCDPaymentKindUnpaidSum();
		ИначеЕсли ТипЗнчCustomsDocument = Тип("ДокументСсылка.CustomsFilesLight") Тогда
			Запрос.УстановитьПараметр("ТПО", CustomsDocument);
			Запрос.Текст = ПолучитьТекстЗапросаТПОPaymentKindUnpaidSum();
		КонецЕсли;
						
		Выборка = Запрос.Выполнить().Выбрать();
		Если Выборка.Следующий() Тогда
			Если ЗначениеЗаполнено(Выборка.SumОстаток) Тогда
				Возврат Выборка.SumОстаток;
			КонецЕсли; 	
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат CustomsDocumentPaymentKindUnpaidSum;
	
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьТекстЗапросаCCDPaymentKindUnpaidSum()
	
	Возврат
		"ВЫБРАТЬ
		|	UnpaidCCDsОстатки.SumОстаток КАК SumОстаток
		|ИЗ
		|	РегистрНакопления.UnpaidCCDs.Остатки(
		|			,
		|			CCD = &CCD
		|				И PaymentKind = &PaymentKind) КАК UnpaidCCDsОстатки";
		
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьТекстЗапросаТПОPaymentKindUnpaidSum()
	
	Возврат
		"ВЫБРАТЬ
		|	НеоплаченныеТПООстатки.SumОстаток КАК SumОстаток
		|ИЗ
		|	РегистрНакопления.НеоплаченныеТПО.Остатки(
		|			,
		|			ТПО = &ТПО
		|				И PaymentKind = &PaymentKind) КАК НеоплаченныеТПООстатки";
		
КонецФункции
	

//////////////////////////////////////////////////////////////////////////////
// ОБЩИЕ

&НаСервере
Процедура ЗаполнитьCustomsPaymentUnallocatedSumИCustomsDocumentPaymentKindUnpaidSum()
	
	CustomsPaymentUnallocatedSum = 0;
	CustomsDocumentPaymentKindUnpaidSum = 0;
	
	СтруктураПараметров = Новый Структура;
	СтруктураТекстов = Новый Структура;
	
	Если ЗначениеЗаполнено(Объект.CustomsPayment) Тогда
		
		СтруктураПараметров.Вставить("CustomsPayment", Объект.CustomsPayment);
		СтруктураТекстов.Вставить("CustomsPaymentUnallocatedSum",
			CustomsСервер.ПолучитьТекстЗапросаCustomsPaymentUnallocatedSum());
			
	КонецЕсли;
		
	Если ЗначениеЗаполнено(Объект.CustomsDocument) И ЗначениеЗаполнено(Объект.PaymentKind) Тогда
	
		СтруктураПараметров.Вставить("PaymentKind", Объект.PaymentKind);
		
		ТипЗнчCustomsDocument = ТипЗнч(Объект.CustomsDocument);
		Если ТипЗнчCustomsDocument = Тип("ДокументСсылка.ГТД") Тогда
			СтруктураПараметров.Вставить("CCD", Объект.CustomsDocument);
			ТекстЗапросаCustomsDocumentPaymentKindUnpaidSum = ПолучитьТекстЗапросаCCDPaymentKindUnpaidSum();
		ИначеЕсли ТипЗнчCustomsDocument = Тип("ДокументСсылка.CustomsFilesLight") Тогда
			СтруктураПараметров.Вставить("ТПО", Объект.CustomsDocument);
			ТекстЗапросаCustomsDocumentPaymentKindUnpaidSum = ПолучитьТекстЗапросаТПОPaymentKindUnpaidSum();
		КонецЕсли;	
		СтруктураТекстов.Вставить("CustomsDocumentPaymentKindUnpaidSum", ТекстЗапросаCustomsDocumentPaymentKindUnpaidSum);
		
	КонецЕсли; 
		
	СтруктураРезультатов = РГСофт.ПолучитьСтруктуруРезультатовТекстовЗапросов(СтруктураТекстов, СтруктураПараметров);
	
	Если СтруктураРезультатов.Свойство("CustomsPaymentUnallocatedSum") Тогда
		
		Выборка = СтруктураРезультатов.CustomsPaymentUnallocatedSum.Выбрать();
		Если Выборка.Следующий()
			И ЗначениеЗаполнено(Выборка.SumОстаток) Тогда
			CustomsPaymentUnallocatedSum = Выборка.SumОстаток;
		КонецЕсли; 
		
	КонецЕсли;
		
	Если СтруктураРезультатов.Свойство("CustomsDocumentPaymentKindUnpaidSum") Тогда
		
		Выборка = СтруктураРезультатов.CustomsDocumentPaymentKindUnpaidSum.Выбрать();
		Если Выборка.Следующий()
			И ЗначениеЗаполнено(Выборка.SumОстаток) Тогда
			CustomsDocumentPaymentKindUnpaidSum = Выборка.SumОстаток;
		КонецЕсли; 
		
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Объект.Sum) Тогда
		Объект.Sum = Мин(CustomsPaymentUnallocatedSum, CustomsDocumentPaymentKindUnpaidSum);
	КонецЕсли;
	
КонецПроцедуры
