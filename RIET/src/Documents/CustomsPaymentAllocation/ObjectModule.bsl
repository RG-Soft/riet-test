
////////////////////////////////////////////////////////////////////////////
// ОБРАБОТКА ЗАПОЛНЕНИЯ

// ДОДЕЛАТЬ
Процедура ОбработкаЗаполнения(Основание)
	
	// ХОРОШО БЫ ЗАПОЛНИТЬ И PAYMENT KIND
	
	ТипЗнчОснования = ТипЗнч(Основание);
	Если ТипЗнчОснования = Тип("ДокументСсылка.CustomsPayment") Тогда
		
		CustomsPayment = Основание;
		
	ИначеЕсли ТипЗнчОснования = Тип("ДокументСсылка.ГТД")
		ИЛИ ТипЗнчОснования = Тип("ДокументСсылка.CustomsFilesLight") Тогда
		
		CustomsDocument = Основание;
		
	ИначеЕсли ТипЗнчОснования = Тип("Структура") Тогда
		
		// СДЕЛАТЬ СТАНДАРТНУЮ ПРОЦЕДУРУ
		Реквизиты = Метаданные().Реквизиты;
		Для Каждого КлючИЗначение Из Основание Цикл
			
			Реквизит = Реквизиты.Найти(КлючИЗначение.Ключ);
			Если Реквизит <> Неопределено И Реквизит.ЗаполнятьИзДанныхЗаполнения Тогда
				ЭтотОбъект[КлючИЗначение.Ключ] = КлючИЗначение.Значение;
			КонецЕсли; 
			
		КонецЦикла; 
		
	КонецЕсли;
	
	Если ЗначениеЗаполнено(CustomsPayment)
		И НЕ ЗначениеЗаполнено(PaymentKind) Тогда
		PaymentKind = ОбщегоНазначения.ПолучитьЗначениеРеквизита(CustomsPayment, "PaymentKind");
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(CustomsPayment)
		И ЗначениеЗаполнено(CustomsDocument) Тогда
		
		СтруктураПодбораCustomsPayments = CustomsСервер.ПолучитьСтруктуруПодбораCustomsPaymentsForAllocation(CustomsDocument, PaymentKind);
		ПодходящиеCustomsPayments = СтруктураПодбораCustomsPayments.CustomsPayments;
		Если ПодходящиеCustomsPayments.Количество() = 1 Тогда
			CustomsPayment = ПодходящиеCustomsPayments[0];
			PaymentKind = СтруктураПодбораCustomsPayments.PaymentKind;
		КонецЕсли; 
		
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(CustomsDocument)
		И ЗначениеЗаполнено(CustomsPayment) Тогда
		
		ПодходящиеCCDs = CustomsСервер.ПолучитьСтруктуруПодбораCCDsForAllocation(CustomsPayment).CCDs;
		Если ПодходящиеCCDs.Количество() = 1 Тогда
			CustomsDocument = ПодходящиеCCDs[0];
		КонецЕсли; 
		
	КонецЕсли; 
	
	Если НЕ ЗначениеЗаполнено(CustomsDocument)
		И ЗначениеЗаполнено(CustomsPayment) Тогда
		
		ПодходящиеТПО = CustomsСервер.ПолучитьСтруктуруПодбораТПОForAllocation(CustomsPayment).ТПО;
		Если ПодходящиеТПО.Количество() = 1 Тогда
			CustomsDocument = ПодходящиеТПО[0];
		КонецЕсли; 
		
	КонецЕсли;
	
КонецПроцедуры


////////////////////////////////////////////////////////////////////////////
// ПЕРЕД ЗАПИСЬЮ

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
			
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	ДозаполнитьРеквизиты();	
	
	ПоместитьДополнительныеДанныеВДополнительныеСвойстваПередЗаписью(РежимЗаписи);
	
	ПроверитьЗаполнениеРеквизитов(Отказ, РежимЗаписи);
		
КонецПроцедуры

Процедура ДозаполнитьРеквизиты()
	
	ОбщегоНазначения.УстановитьЗначение(PaymentKind, СокрЛП(PaymentKind));
	ОбщегоНазначения.УстановитьЗначение(Comment, СокрЛП(Comment));
	
	Если НЕ ЗначениеЗаполнено(CreationDate) Тогда
		CreationDate = ТекущаяДата();
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(LastModified) Тогда
		LastModified = ТекущаяДата();
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Responsible) Тогда
		Responsible = ПараметрыСеанса.ТекущийПользователь;
	КонецЕсли;
	
КонецПроцедуры

Процедура ПоместитьДополнительныеДанныеВДополнительныеСвойстваПередЗаписью(РежимЗаписи)
	
	СтруктураТекстов = Новый Структура;
	СтруктураПараметров = Новый Структура;
					
	// Запросы проверок заполнения
	Если НЕ ПометкаУдаления Тогда
				
		Если РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда
			
			Если ЗначениеЗаполнено(CustomsPayment) Тогда
				
				СтруктураПараметров.Вставить("CustomsPayment", CustomsPayment);
				СтруктураТекстов.Вставить("РеквизитыCustomsPayment", 
					"ВЫБРАТЬ
					|	CustomsPayment.Customs,
					|	CustomsPayment.BankAccount.SoldTo КАК ParentCompany,
					|	CustomsPayment.PaymentKind
					|ИЗ
					|	Документ.CustomsPayment КАК CustomsPayment
					|ГДЕ
					|	CustomsPayment.Ссылка = &CustomsPayment");
											
			КонецЕсли;
			
			Если ЗначениеЗаполнено(CustomsDocument) Тогда
				
				СтруктураПараметров.Вставить("CustomsDocument", CustomsDocument);
				
				ТипЗнчCustomsDocument = ТипЗнч(CustomsDocument);
				Если ТипЗнчCustomsDocument = Тип("ДокументСсылка.ГТД") Тогда
					
					ТекстЗапросаРеквизитовCustomsDocument =
						"ВЫБРАТЬ
						|	ГТД.CustomsPost.Customs КАК Customs,
						|	ГТД.SoldTo.ParentCompanyForPayments КАК ParentCompanyForPayments
						|ИЗ
						|	Документ.ГТД КАК ГТД
						|ГДЕ
						|	ГТД.Ссылка = &CustomsDocument";
						
				ИначеЕсли ТипЗнчCustomsDocument = Тип("ДокументСсылка.CustomsFilesLight") Тогда
					
					ТекстЗапросаРеквизитовCustomsDocument =
						"ВЫБРАТЬ
						|	CustomsFilesLight.CustomsPost.Customs КАК Customs,
						|	CustomsFilesLight.SoldTo.ParentCompanyForPayments КАК ParentCompanyForPayments,
						|	CustomsFilesLight.TypeOfTransaction
						|ИЗ
						|	Документ.CustomsFilesLight КАК CustomsFilesLight
						|ГДЕ
						|	CustomsFilesLight.Ссылка = &CustomsDocument";
					
				КонецЕсли;
				
				СтруктураТекстов.Вставить("РеквизитыCustomsDocument", ТекстЗапросаРеквизитовCustomsDocument);
				
			КонецЕсли;
			
		КонецЕсли; 
		
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	СтруктураРезультатов = РГСофт.ПолучитьСтруктуруРезультатовТекстовЗапросов(СтруктураТекстов, СтруктураПараметров);
	
	ДополнительныеСвойства.Вставить("ВыборкаРеквизитовCustomsPayment", Неопределено);
	Если СтруктураРезультатов.Свойство("РеквизитыCustomsPayment") Тогда
		ДополнительныеСвойства.ВыборкаРеквизитовCustomsPayment = СтруктураРезультатов.РеквизитыCustomsPayment.Выбрать();
		ДополнительныеСвойства.ВыборкаРеквизитовCustomsPayment.Следующий();
	КонецЕсли;
	
	ДополнительныеСвойства.Вставить("ВыборкаРеквизитовCustomsDocument", Неопределено);
	Если СтруктураРезультатов.Свойство("РеквизитыCustomsDocument") Тогда
		ДополнительныеСвойства.ВыборкаРеквизитовCustomsDocument = СтруктураРезультатов.РеквизитыCustomsDocument.Выбрать();
		ДополнительныеСвойства.ВыборкаРеквизитовCustomsDocument.Следующий();
	КонецЕсли;
	
КонецПроцедуры

Процедура ПроверитьЗаполнениеРеквизитов(Отказ, РежимЗаписи)
	
	Если ПометкаУдаления Тогда
		Возврат;
	КонецЕсли; 
		
	Если НЕ ЗначениеЗаполнено(Дата) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Поле ""Date"" не заполнено!",
			ЭтотОбъект, "Дата", , Отказ);
	КонецЕсли;
	
	Если РежимЗаписи <> РежимЗаписиДокумента.Проведение Тогда
		Возврат;
	КонецЕсли; 
				
    Если НЕ ЗначениеЗаполнено(CustomsPayment) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Поле ""Customs payment"" не заполнено!",
			ЭтотОбъект, "CustomsPayment", , Отказ);
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(CustomsDocument) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Поле ""Customs document"" не заполнено!",
			ЭтотОбъект, "CustomsDocument", , Отказ);
	КонецЕсли;            
	
	Если НЕ ЗначениеЗаполнено(PaymentKind) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Поле ""Payment kind"" не заполнено!",
			ЭтотОбъект, "PaymentKind", , Отказ);
	КонецЕсли;
	
	Если ЗначениеЗаполнено(CustomsPayment)
		И ЗначениеЗаполнено(CustomsDocument) Тогда
		
		ВыборкаРеквизитовCustomsPayment = ДополнительныеСвойства.ВыборкаРеквизитовCustomsPayment;
		ВыборкаРеквизитовCustomsDocument = ДополнительныеСвойства.ВыборкаРеквизитовCustomsDocument;

		Если ВыборкаРеквизитовCustomsPayment.Customs <> ВыборкаРеквизитовCustomsDocument.Customs Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Customs в Customs payment  (" + ВыборкаРеквизитовCustomsPayment.Customs + ") не соответствует customs в Сustoms document (" + ВыборкаРеквизитовCustomsDocument.Customs + ")!",
				ЭтотОбъект, , , Отказ);
		КонецЕсли; 
		
		Если ВыборкаРеквизитовCustomsPayment.ParentCompany <> ВыборкаРеквизитовCustomsDocument.ParentCompanyForPayments Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Parent co. """ + ВыборкаРеквизитовCustomsPayment.ParentCompany + """ of Customs payment differs from Parent co. for payments """ + ВыборкаРеквизитовCustomsDocument.ParentCompanyForPayments + """ of Customs file!",
				ЭтотОбъект, , , Отказ);
		КонецЕсли; 
		
		Если ЗначениеЗаполнено(PaymentKind) И ЗначениеЗаполнено(ВыборкаРеквизитовCustomsPayment.PaymentKind)
			И СокрЛП(ВыборкаРеквизитовCustomsPayment.PaymentKind) <> "9070"
			И PaymentKind <> ВыборкаРеквизитовCustomsPayment.PaymentKind Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Payment kind в Customs payment (" + ВыборкаРеквизитовCustomsPayment.PaymentKind + ") не соответствует Payment kind в документе (" + PaymentKind + ")!",
				ЭтотОбъект, "CusomsPayment", , Отказ);
		КонецЕсли;
	
	КонецЕсли; 
	
	Если НЕ ЗначениеЗаполнено(Sum) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Поле ""Sum"" не заполнено!",
			ЭтотОбъект, "Sum", , Отказ);
	КонецЕсли; 
		
КонецПроцедуры


////////////////////////////////////////////////////////////////////////////
// ОБРАБОТКА ПРОВЕДЕНИЯ

Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	
	ДвижениеПоUnallocatedCustomsPayments = Движения.UnallocatedCustomsPayments;
	ДвижениеПоUnallocatedCustomsPayments.Очистить();
	Движение = ДвижениеПоUnallocatedCustomsPayments.ДобавитьРасход();
	Движение.Период	= Дата;
	Движение.CustomsPayment = CustomsPayment;
	Движение.Sum = Sum;
	ДвижениеПоUnallocatedCustomsPayments.Записать();
	
	СтруктураПараметров = Новый Структура;
	СтруктураТекстов = Новый Структура;
	
	СтруктураПараметров.Вставить("PaymentKind", PaymentKind);
	
	ТипЗнчCustomsDocument = ТипЗнч(CustomsDocument);
	Если ТипЗнчCustomsDocument = Тип("ДокументСсылка.ГТД") Тогда
		
		ДвиженияПоUnpaidCCDs = Движения.UnpaidCCDs;
		ДвиженияПоUnpaidCCDs.Очистить();	
		Движение = ДвиженияПоUnpaidCCDs.ДобавитьРасход();
		Движение.Период	= Дата;
		Движение.CCD = CustomsDocument;
		Движение.PaymentKind = PaymentKind;
		Движение.Sum = Sum;
		ДвиженияПоUnpaidCCDs.Записать();
		
		СтруктураПараметров.Вставить("CCD", CustomsDocument);
		ТекстЗапросаОтрицательныхОстатковCustomsDocument = 
			"ВЫБРАТЬ
			|	UnpaidCCDsОстатки.SumОстаток
			|ИЗ
			|	РегистрНакопления.UnpaidCCDs.Остатки(
			|			,
			|			CCD = &CCD
			|				И PaymentKind = &PaymentKind) КАК UnpaidCCDsОстатки
			|ГДЕ
			|	UnpaidCCDsОстатки.SumОстаток < 0";	
		
	ИначеЕсли ТипЗнчCustomsDocument = Тип("ДокументСсылка.CustomsFilesLight") Тогда
		
		ДвиженияПоНеоплаченнымТПО = Движения.НеоплаченныеТПО;
		ДвиженияПоНеоплаченнымТПО.Очистить();	
		Движение = ДвиженияПоНеоплаченнымТПО.ДобавитьРасход();
		Движение.Период	= Дата;
		Движение.ТПО = CustomsDocument;
		Движение.PaymentKind = PaymentKind;
		Движение.Sum = Sum;
		ДвиженияПоНеоплаченнымТПО.Записать();
		
		СтруктураПараметров.Вставить("ТПО", CustomsDocument);
		ТекстЗапросаОтрицательныхОстатковCustomsDocument = 
			"ВЫБРАТЬ
			|	НеоплаченныеТПООстатки.SumОстаток
			|ИЗ
			|	РегистрНакопления.НеоплаченныеТПО.Остатки(
			|			,
			|			ТПО = &ТПО
			|				И PaymentKind = &PaymentKind) КАК НеоплаченныеТПООстатки
			|ГДЕ
			|	НеоплаченныеТПООстатки.SumОстаток < 0";
		
	КонецЕсли;
	
	СтруктураТекстов.Вставить("ОтрицательныеОстаткиCustomsDocument",
		ТекстЗапросаОтрицательныхОстатковCustomsDocument);
	
	СтруктураПараметров.Вставить("CustomsPayment", CustomsPayment);
	СтруктураТекстов.Вставить("ОтрицательныеОстаткиCustomsPayment",
		"ВЫБРАТЬ
		|	UnallocatedCustomsPaymentsОстатки.SumОстаток
		|ИЗ
		|	РегистрНакопления.UnallocatedCustomsPayments.Остатки(, CustomsPayment = &CustomsPayment) КАК UnallocatedCustomsPaymentsОстатки
		|ГДЕ
		|	UnallocatedCustomsPaymentsОстатки.SumОстаток < 0");
		
	СтруктураРезультатов = РГСофт.ПолучитьСтруктуруРезультатовТекстовЗапросов(СтруктураТекстов, СтруктураПараметров);
	
	Выборка = СтруктураРезультатов.ОтрицательныеОстаткиCustomsPayment.Выбрать();
	Если Выборка.Следующий() Тогда
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"По """ + CustomsPayment + """ перерасход " + (-Выборка.SumОстаток) + "!",
			ЭтотОбъект, "Sum", , Отказ);
			
	КонецЕсли;
	
	Выборка = СтруктураРезультатов.ОтрицательныеОстаткиCustomsDocument.Выбрать();
	Если Выборка.Следующий() Тогда
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"По """ + CustomsDocument + """ и Payment kind " + PaymentKind + " переплачено " + (-Выборка.SumОстаток) + "!",
			ЭтотОбъект, "Sum", , Отказ);
		
	КонецЕсли;
	
	ДвиженияПоCustomsDeposits(Отказ, ДополнительныеСвойства.ВыборкаРеквизитовCustomsDocument);
	
КонецПроцедуры

Процедура ДвиженияПоCustomsDeposits(Отказ, ВыборкаРеквизитовCustomsDocument)
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	Движения.CustomsDeposits.Очистить();
	Движения.CustomsDeposits.Записывать = Истина;
	
	Если ТипЗнч(CustomsDocument) <> Тип("ДокументСсылка.CustomsFilesLight") Тогда
		Возврат;
	КонецЕсли;
	
	Если ВыборкаРеквизитовCustomsDocument.TypeOfTransaction <> Перечисления.TypesOfCustomsFileLightTransaction.CustomsBond Тогда
		Возврат;
	КонецЕсли;
		
	Движения.CustomsDeposits.ДобавитьЗапись(
		ВидДвиженияНакопления.Приход,
		Дата,
		CustomsDocument,
		Sum);
		     		
КонецПроцедуры


