
/////////////////////////////////////////////////////////////////////////
// ПЕРЕД ЗАПИСЬЮ

Процедура ПередЗаписью(Отказ)
			
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	ДозаполнитьРеквизиты();
	
	ПроверитьРеквизитыБезДополнительныхДанных(Отказ);
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	ПоместитьДополнительныеДанныеВДополнительныеСвойства();
	
	ПроверитьРеквизитыСДополнительнымиДанными(
		Отказ,
		ДополнительныеСвойства.ВыборкаДублейПоНаименованию,
		ДополнительныеСвойства.ВыборкаДублейПоTMS);
	
КонецПроцедуры

Процедура ДозаполнитьРеквизиты()
	
	Наименование 	 = СокрЛП(Наименование);
	NameRus      	 = СокрЛП(NameRus);
	SoldToAddress	 = СокрЛП(SoldToAddress);
	SoldToAddressRus = СокрЛП(SoldToAddressRus);
	CompanyCode 	 = СокрЛП(CompanyCode);
	CountryCode 	 = СокрЛП(CountryCode);
	ERPID 			 = СокрЛП(ERPID);	
	FinanceLocCode	 = СокрЛП(FinanceLocCode);
	FinanceProcess   = СокрЛП(FinanceProcess);
	
	Если ЭтоНовый() Тогда
		CreatedBy = ПараметрыСеанса.ТекущийПользователь;
		CreationDate = ТекущаяДата();
	КонецЕсли;
	
КонецПроцедуры

Процедура ПроверитьРеквизитыБезДополнительныхДанных(Отказ)
	
	Если ПометкаУдаления Тогда
		Возврат;
	КонецЕсли;
		
	Если НЕ ЗначениеЗаполнено(Наименование) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"""Name"" is empty!",
			ЭтотОбъект, "Наименование", , Отказ);
	КонецЕсли;
	
	Если InTMS Тогда 
		
		Если НЕ ЗначениеЗаполнено(SoldToAddress) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"""Sold-to address"" is empty!",
				ЭтотОбъект, "SoldToAddress", , Отказ);
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(ERPID) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"""ERP ID"" is empty!",
				ЭтотОбъект, "ERPID", , Отказ);
		КонецЕсли;

		Если НЕ ЗначениеЗаполнено(CompanyCode) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"""Company code"" is empty!",
				ЭтотОбъект, "CompanyCode", , Отказ);
		КонецЕсли;

		Если НЕ ЗначениеЗаполнено(CountryCode) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"""Country code"" is empty!",
				ЭтотОбъект, "CountryCode", , Отказ);
		КонецЕсли;

		Если НЕ ЗначениеЗаполнено(FinanceLocCode) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"""Finance loc code"" is empty!",
				ЭтотОбъект, "FinanceLocCode", , Отказ);
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(FinanceProcess) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"""Finance process"" is empty!",
				ЭтотОбъект, "FinanceProcess", , Отказ);
		КонецЕсли;
				
	КонецЕсли;

КонецПроцедуры

Процедура ПоместитьДополнительныеДанныеВДополнительныеСвойства()
	
	СтруктураПараметров = Новый Структура;
	СтруктураТекстов = Новый Структура;
	
	Если НЕ ПометкаУдаления Тогда
		
		СтруктураПараметров.Вставить("Ссылка", Ссылка);
					
		Если InTMS Тогда
			
			СтруктураПараметров.Вставить("ERPID", ERPID);
			СтруктураПараметров.Вставить("CountryCode", CountryCode);
			СтруктураПараметров.Вставить("CompanyCode", CompanyCode);
			СтруктураПараметров.Вставить("FinanceLocCode", FinanceLocCode);
			СтруктураПараметров.Вставить("FinanceProcess", FinanceProcess);
			
			СтруктураТекстов.Вставить("ДублиПоTMS",
				"ВЫБРАТЬ
				|	LegalEntities.Представление
				|ИЗ
				|	Справочник.LegalEntities КАК LegalEntities
				|ГДЕ
				|	LegalEntities.InTMS
				|	И LegalEntities.ERPID = &ERPID
				|	И LegalEntities.CountryCode = &CountryCode
				|	И LegalEntities.CompanyCode = &CompanyCode
				|	И LegalEntities.FinanceLocCode = &FinanceLocCode
				|	И LegalEntities.FinanceProcess = &FinanceProcess
				|	И LegalEntities.Ссылка <> &Ссылка
				|	И НЕ LegalEntities.ПометкаУдаления");
				
		Иначе
			
			СтруктураПараметров.Вставить("Наименование", Наименование);
			СтруктураТекстов.Вставить("ДублиПоНаименованию",
				"ВЫБРАТЬ
				|	LegalEntities.Представление
				|ИЗ
				|	Справочник.LegalEntities КАК LegalEntities
				|ГДЕ
				|	LegalEntities.Наименование = &Наименование
				|	И LegalEntities.Ссылка <> &Ссылка
				|	И НЕ LegalEntities.ПометкаУдаления");
		
		КонецЕсли;
			
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	СтруктураРезультатов = РГСофт.ПолучитьСтруктуруРезультатовТекстовЗапросов(СтруктураТекстов, СтруктураПараметров);
	
	ДополнительныеСвойства.Вставить("ВыборкаДублейПоНаименованию", Неопределено);
	Если СтруктураРезультатов.Свойство("ДублиПоНаименованию") Тогда
		ДополнительныеСвойства.ВыборкаДублейПоНаименованию = СтруктураРезультатов.ДублиПоНаименованию.Выбрать();
	КонецЕсли;
	
	ДополнительныеСвойства.Вставить("ВыборкаДублейПоTMS", Неопределено);
	Если СтруктураРезультатов.Свойство("ДублиПоTMS") Тогда
		ДополнительныеСвойства.ВыборкаДублейПоTMS = СтруктураРезультатов.ДублиПоTMS.Выбрать();
	КонецЕсли;
	
КонецПроцедуры

Процедура ПроверитьРеквизитыСДополнительнымиДанными(Отказ, ВыборкаДублейПоНаименованию, ВыборкаДублейПоTMS)
	
	Если ПометкаУдаления Тогда
		Возврат;
	КонецЕсли;
		
	Если InTMS Тогда
		
		Пока ВыборкаДублейПоTMS.Следующий() Цикл
		
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"There is already Seller """ + СокрЛП(ВыборкаДублейПоTMS.Представление) + """ with the same ERP ID, Country code, Company code, Finance loc code and Finance process!",
				ЭтотОбъект, , , Отказ);
			
		КонецЦикла;
		
	Иначе
		
		Пока ВыборкаДублейПоНаименованию.Следующий() Цикл
		
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"There is already Seller with the same Name!",
				ЭтотОбъект, "Наименование", , Отказ);
		
		КонецЦикла;
		
	КонецЕсли;
	
КонецПроцедуры