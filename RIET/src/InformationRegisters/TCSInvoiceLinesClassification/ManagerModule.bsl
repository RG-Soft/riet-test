
Процедура ЗарегистрироватьДляВыгрузкиПриНеобходимости(InvoiceLinesClassification, ParentCompany) Экспорт
	       		
	НаборЗаписей = СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.InvoiceLinesClassification.Установить(InvoiceLinesClassification);
	НаборЗаписей.Отбор.ParentCompany.Установить(ParentCompany);
			
	ТекЗапись = НаборЗаписей.Добавить();
	ТекЗапись.InvoiceLinesClassification = InvoiceLinesClassification;
	ТекЗапись.ParentCompany = ParentCompany;
	ТекЗапись.LastModified = ТекущаяДата();
		
	НаборЗаписей.Записать(Истина);
	            		
КонецПроцедуры

Функция ПолучитьТаблицуLastModifiedBefore(LastModifiedBefore) Экспорт
	
	// Возвращает таблицу данных регистра, у которых Last modified меньше указанной
	
	Если НЕ ЗначениеЗаполнено(LastModifiedBefore) Тогда
		ВызватьИсключение "Last modified before is empty!";
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("LastModifiedBefore", LastModifiedBefore);
	Запрос.Текст =
		"ВЫБРАТЬ
		|	TCSInvoiceLinesClassification.InvoiceLinesClassification,
		|	TCSInvoiceLinesClassification.InvoiceLinesClassification.InvoiceLinesMatching КАК InvoiceLinesMatching,
		|	TCSInvoiceLinesClassification.ParentCompany
		|ИЗ
		|	РегистрСведений.TCSInvoiceLinesClassification КАК TCSInvoiceLinesClassification
		|ГДЕ
		|	TCSInvoiceLinesClassification.LastModified < &LastModifiedBefore";
		
	Возврат Запрос.Выполнить().Выгрузить();
	
КонецФункции

Процедура УдалитьЗапись(InvoiceLinesClassification, ParentCompany) Экспорт
	
	Если НЕ ЗначениеЗаполнено(InvoiceLinesClassification) Тогда
		ВызватьИсключение "Invoice Lines Classification is empty!";
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(InvoiceLinesClassification) Тогда
		ВызватьИсключение "Parent company is empty!";
	КонецЕсли;

	НаборЗаписей = СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.InvoiceLinesClassification.Установить(InvoiceLinesClassification);
	НаборЗаписей.Отбор.ParentCompany.Установить(ParentCompany);
	НаборЗаписей.Записать(Истина);
	
КонецПроцедуры

