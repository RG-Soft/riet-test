
/////////////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТКА ЗАПОЛНЕНИЯ

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, СтандартнаяОбработка)
	
	Если ТипЗнч(ДанныеЗаполнения) = Тип("ДокументСсылка.ГТД") Тогда
		DT = ДанныеЗаполнения;
		DT = ОбщегоНазначения.ПолучитьЗначениеРеквизита(DT, "Номер");
	КонецЕсли;
	
КонецПроцедуры


/////////////////////////////////////////////////////////////////////////////////////////
// ПЕРЕД ЗАПИСЬЮ

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	ДозаполнитьРеквизитыБезДополнительныхДанных();
	
	ПоместитьДополнительныеДанныеВДополнительныеСвойства(РежимЗаписи);
	
	ПроверитьВозможностьИзменения(
		Отказ,
		ДополнительныеСвойства.ВыборкаПроведенныхAllocations);
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	ПроверитьЗаполнениеРеквизитов(
		Отказ,
		РежимЗаписи,
		ДополнительныеСвойства.ВыборкаДублей,
		ДополнительныеСвойства.ВыборкаРеквизитовDT);
	
КонецПроцедуры


/////////////////////////////////////////////////////////////////////////////////////////

Процедура ДозаполнитьРеквизитыБезДополнительныхДанных()
	
	Дата = НачалоДня(Дата);
	
	DTNo = СокрЛП(DTNo);
	
	Comments = СокрЛП(Comments);
	
	Если НЕ ЗначениеЗаполнено(ProcessLevel) Тогда
		ProcessLevel = РГСофтСерверПовтИспСеанс.ПолучитьЗначениеРеквизита(ПараметрыСеанса.ТекущийПользователь, "ProcessLevel");
	КонецЕсли;
	
	Если ЭтоНовый() Тогда		
		CreatedBy = ПараметрыСеанса.ТекущийПользователь;
		CreationDate = ТекущаяДата();	
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(ModifiedBy) Тогда
		ModifiedBy = ПараметрыСеанса.ТекущийПользователь;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(ModificationDate) Тогда
		ModificationDate = ТекущаяДата();
	КонецЕсли;
	
КонецПроцедуры


/////////////////////////////////////////////////////////////////////////////////////////

Процедура ПоместитьДополнительныеДанныеВДополнительныеСвойства(РежимЗаписи)
	
	СтруктураТекстов = Новый Структура;
	СтруктураПараметров = Новый Структура;
	
	СтруктураПараметров.Вставить("Ссылка", Ссылка);
	
	Если Проведен Тогда
		
		// Проверим, что документ не выдергивают из хронологической последовательности	
		СтруктураТекстов.Вставить("ПроведенныеAllocations",
			"ВЫБРАТЬ
			|	CustomsPaymentAllocation.Ссылка,
			|	CustomsPaymentAllocation.Представление
			|ИЗ
			|	Документ.CustomsPaymentAllocation КАК CustomsPaymentAllocation
			|ГДЕ
			|	CustomsPaymentAllocation.CustomsDocument = &Ссылка
			|	И CustomsPaymentAllocation.Проведен");
		
	КонецЕсли;
	
	Если РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда
		
		Если ЗначениеЗаполнено(Дата) И ЗначениеЗаполнено(DTNo) Тогда
			
			// Проверим, что нет дублей
			СтруктураПараметров.Вставить("DTNo", DTNo);
			СтруктураПараметров.Вставить("Дата", Дата);	
			СтруктураТекстов.Вставить("Дубли",
				"ВЫБРАТЬ
				|	FutureCustomsPayments.Ссылка,
				|	FutureCustomsPayments.Представление
				|ИЗ
				|	Документ.FutureCustomsPayments КАК FutureCustomsPayments
				|ГДЕ
				|	FutureCustomsPayments.DTNo = &DTNo
				|	И FutureCustomsPayments.Дата = &Дата
				|	И FutureCustomsPayments.Проведен
				|	И FutureCustomsPayments.Ссылка <> &Ссылка");
			
		КонецЕсли;
		
		Если ЗначениеЗаполнено(DT) Тогда
			
			СтруктураПараметров.Вставить("DT", DT);
			СтруктураТекстов.Вставить("РеквизитыDT",
				"ВЫБРАТЬ
				|	ГТД.Номер,
				|	ГТД.Дата,
				|	ГТД.Regime.PermanentTemporary КАК PermanentTemporary,
				|	ГТД.Проведен,
				|	ГТД.Представление
				|ИЗ
				|	Документ.ГТД КАК ГТД
				|ГДЕ
				|	ГТД.Ссылка = &DT");
			
		КонецЕсли;
		
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	СтруктураРезультатов = РГСофт.ПолучитьСтруктуруРезультатовТекстовЗапросов(СтруктураТекстов, СтруктураПараметров);
	
	ДополнительныеСвойства.Вставить("ВыборкаПроведенныхAllocations", Неопределено);
	Если СтруктураРезультатов.Свойство("ПроведенныеAllocations") Тогда
		ДополнительныеСвойства.ВыборкаПроведенныхAllocations = СтруктураРезультатов.ПроведенныеAllocations.Выбрать();
	КонецЕсли;
	
	ДополнительныеСвойства.Вставить("ВыборкаДублей", Неопределено);
	Если СтруктураРезультатов.Свойство("Дубли") Тогда
		ДополнительныеСвойства.ВыборкаДублей = СтруктураРезультатов.Дубли.Выбрать();
	КонецЕсли;

	ДополнительныеСвойства.Вставить("ВыборкаРеквизитовDT", Неопределено);
	Если СтруктураРезультатов.Свойство("РеквизитыDT") Тогда
		ДополнительныеСвойства.ВыборкаРеквизитовDT = СтруктураРезультатов.РеквизитыDT.Выбрать();
		ДополнительныеСвойства.ВыборкаРеквизитовDT.Следующий();
	КонецЕсли;
	
КонецПроцедуры


/////////////////////////////////////////////////////////////////////////////////////////

Процедура ПроверитьВозможностьИзменения(Отказ, ВыборкаПроведенныхAllocatins)
	
	Если НЕ Проведен Тогда
		Возврат;
	КонецЕсли;
	
	Пока ВыборкаПроведенныхAllocatins.Следующий() Цикл
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"You can not change " + ЭтотОбъект + ", because there is " + ВыборкаПроведенныхAllocatins.Представление + "!",
			ВыборкаПроведенныхAllocatins.Ссылка, , , Отказ);
		
	КонецЦикла;
	
КонецПроцедуры


/////////////////////////////////////////////////////////////////////////////////////////

Процедура ПроверитьЗаполнениеРеквизитов(Отказ, РежимЗаписи, ВыборкаДублей, ВыборкаРеквизитовDT)
	
	Если НЕ ЭтоНовый() И НЕ ЗначениеЗаполнено(СокрЛП(Номер)) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"""No."" is empty!",
			ЭтотОбъект, "Номер", , Отказ);
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(ProcessLevel) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"""Process level"" is empty!",
			ЭтотОбъект, "ProcessLevel", , Отказ);
	КонецЕсли;
	
	Если ПометкаУдаления Тогда
		Возврат;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Дата) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"""Due date"" is empty!",
			ЭтотОбъект, "Дата", , Отказ);
	КонецЕсли;
		
	Если РежимЗаписи <> РежимЗаписиДокумента.Проведение Тогда
		Возврат;
	КонецЕсли;
			
	Если НЕ ЗначениеЗаполнено(DTNo) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"""DT no."" is empty!",
			ЭтотОбъект, "DTNo", , Отказ);
	КонецЕсли;
	
	// Проверим, что нет дублей
	Если ЗначениеЗаполнено(DTNo) И ЗначениеЗаполнено(Дата) Тогда
		
		Пока ВыборкаДублей.Следующий() Цикл	
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"There is " + ВыборкаДублей.Представление + " for DT #" + DTNo + " and Due date " + Дата + "!",
				ВыборкаДублей.Ссылка,,, Отказ);	
		КонецЦикла;
		
	КонецЕсли;
	
	Если ЗначениеЗаполнено(DT) Тогда
		
		Если НЕ (ВыборкаРеквизитовDT.Проведен) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"""" + ВыборкаРеквизитовDT.Представление + """ is not posted!",
				ЭтотОбъект, "DT", , Отказ);
		КонецЕсли;
		
		Если НЕ ВыборкаРеквизитовDT.PermanentTemporary = Перечисления.PermanentTemporary.Temporary Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"""" + ВыборкаРеквизитовDT.Представление + """ is not for temporary import!",
				ЭтотОбъект, "DT", , Отказ);
		КонецЕсли;
		
		Если ЗначениеЗаполнено(DTNo) И DTNo <> СокрЛП(ВыборкаРеквизитовDT.Номер) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"""DT no."" differs from No. of DT!",
				ЭтотОбъект, "DTNo", , Отказ);
		КонецЕсли;
			
		Если ЗначениеЗаполнено(Дата) И Дата < ВыборкаРеквизитовDT.Дата Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"""Due date"" is less than Date of DT!",
				ЭтотОбъект, "Дата", , Отказ);
		КонецЕсли;
		
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Amount) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"""Amount"" is empty!",
			ЭтотОбъект, "Amount", , Отказ);
	КонецЕсли;
	
КонецПроцедуры


/////////////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТКА ПРОВЕДЕНИЯ

Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	
	ДвиженияПоUnpaidFutureCustomsPayments = Движения.UnpaidFutureCustomsPayments;
	ДвиженияПоUnpaidFutureCustomsPayments.Очистить();
	ДвиженияПоUnpaidFutureCustomsPayments.Записывать = Истина;
	
	Движение = ДвиженияПоUnpaidFutureCustomsPayments.ДобавитьПриход();
	Движение.Период = Дата;
	Движение.FutureCustomsPayment = Ссылка;
	Движение.Amount = Amount;
	
КонецПроцедуры

