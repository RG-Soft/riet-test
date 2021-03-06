
////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТКА ЗАПОЛНЕНИЯ

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, СтандартнаяОбработка)
	
	Если ТипЗнч(ДанныеЗаполнения) = Тип("Структура")
		И ДанныеЗаполнения.Свойство("Recipients") Тогда
		
		Для Каждого Recipient Из ДанныеЗаполнения.Recipients Цикл
			НоваяСтрокаТЧ = Recipients.Добавить();
			НоваяСтрокаТЧ.Recipient = Recipient;
		КонецЦикла;
		
	КонецЕсли;
	
КонецПроцедуры


////////////////////////////////////////////////////////////////////////////////
// ПЕРЕД ЗАПИСЬЮ

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	ДозаполнитьРеквизитыБезДополнительныхДанных(РежимЗаписи);
	
	ПроверитьВозможностьИзменения(Отказ, РежимЗаписи);
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	ПроверитьЗаполнениеРеквизитов(Отказ, РежимЗаписи);
	
КонецПроцедуры


////////////////////////////////////////////////////////////////////////////////

Процедура ДозаполнитьРеквизитыБезДополнительныхДанных(РежимЗаписи)
	
	Если РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда
		Дата = ТекущаяДата();
	КонецЕсли;
	
	Subject = СокрЛП(Subject);
	Body = СокрЛП(Body);
	ReplyTo = СокрЛП(ReplyTo);
	
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
	
	ИндексСтроки = 0;
	Пока ИндексСтроки < Recipients.Количество() Цикл
		
		СтрокаТЧ = Recipients[ИндексСтроки];
		СтрокаТЧ.Recipient = СокрЛП(СтрокаТЧ.Recipient);
		Если НЕ ЗначениеЗаполнено(СтрокаТЧ.Recipient) Тогда
			Recipients.Удалить(ИндексСтроки);
		Иначе
			ИндексСтроки = ИндексСтроки+1;
		КонецЕсли;
		
	КонецЦикла;
	Recipients.Свернуть("Recipient", "");
	МассивRecipients = Recipients.ВыгрузитьКолонку("Recipient");
	ListOfRecipients = СтроковыеФункцииКлиентСервер.ПолучитьСтрокуИзМассиваПодстрок(МассивRecipients, ", ");
	
КонецПроцедуры


////////////////////////////////////////////////////////////////////////////////

Процедура ПроверитьВозможностьИзменения(Отказ, РежимЗаписи)
	
	// Запретим отмену проведения, так как проведение - это отправка, а отменить отправку нельзя
	Если РежимЗаписи = РежимЗаписиДокумента.ОтменаПроведения Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"You can not return message that was already sent!",
			ЭтотОбъект,,, Отказ);
	КонецЕсли;
	
КонецПроцедуры


////////////////////////////////////////////////////////////////////////////////

Процедура ПроверитьЗаполнениеРеквизитов(Отказ, РежимЗаписи)
	
	Если РежимЗаписи <> РежимЗаписиДокумента.Проведение Тогда
		Возврат;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Object) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Object is empty!",
			ЭтотОбъект, "Object", , Отказ);
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Subject) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Subject is empty!",
			ЭтотОбъект, "Subject", , Отказ);
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Body) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Body is empty!",
			ЭтотОбъект, "Body", , Отказ);
	КонецЕсли;
	
	Если Recipients.Количество() = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Recipients are empty!",
			ЭтотОбъект, "Recipients", , Отказ);
	КонецЕсли;
	
КонецПроцедуры


////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТКА ПРОВЕДЕНИЯ

Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	
	// { RGS DKazanskiy 31.05.2018 14:45:50 - S-I-0005358
	// Вместо непосредственной отправки письма скидываем его в очередь на отправку. 
	АдресаОтправки = "";
	Для Каждого СтрокаТЧ Из Recipients Цикл	
		АдресаОтправки = АдресаОтправки + ?(ПустаяСтрока(АдресаОтправки), "", ",") + СтрокаТЧ.Recipient;
	КонецЦикла;
	
	ТипТекстаПисьма = ТипТекста;
	
	Если НЕ ЗначениеЗаполнено(ТипТекста) Тогда
		ТипТекстаПисьма = Перечисления.ТипыТекстовЭлектронныхПисем.ПростойТекст;
	КонецЕсли;
	
	РГСофт.ЗарегистрироватьПочтовоеСообщение(АдресаОтправки, Subject, Body, Неопределено, ТипТекстаПисьма, Copy);
	
	// } RGS DKazanskiy 31.05.2018 14:46:12 - S-I-0005358

	
	//// Проведение - это отправка сообщения
	//СистемнаяУчетнаяЗапись = РаботаСПочтовымиСообщениями.СистемнаяУчетнаяЗапись();
	//	
	//ПараметрыПисьма = Новый Структура;

	//МассивСтруктурКому = Новый Массив;
	//Для Каждого СтрокаТЧ Из Recipients Цикл	
	//	МассивСтруктурКому.Добавить(Новый Структура("Адрес, Представление", СтрокаТЧ.Recipient, СтрокаТЧ.Recipient));	
	//КонецЦикла;
	//
	//// { RGS AArsentev 17.05.2018 S-I-0005277
	//Если ЗначениеЗаполнено(ReplyTo) Тогда
	//	Copy = ?(ЗначениеЗаполнено(Copy), Copy + ", " + ReplyTo, ReplyTo);
	//КонецЕсли;
	//// } RGS AArsentev 17.05.2018 S-I-0005277
	//
	//ПараметрыПисьма.Вставить("Кому", МассивСтруктурКому);

	//ПараметрыПисьма.Вставить("Тема", 		Subject);
	//ПараметрыПисьма.Вставить("Тело", 		Body);
	//ПараметрыПисьма.Вставить("АдресОтвета", ReplyTo);
	//ПараметрыПисьма.Вставить("Копии", 		Copy);
	//
	//// ++ КДС
	//Если НЕ ЗначениеЗаполнено(ТипТекста) Тогда
	//	ПараметрыПисьма.Вставить("ТипТекста", 	Перечисления.ТипыТекстовЭлектронныхПисем.ПростойТекст);
	//Иначе
	//	ПараметрыПисьма.Вставить("ТипТекста", 	ТипТекста);
	//КонецЕсли;
	//// -- КДС

	//// Попробуем отправить сообщение
	//ПисьмоОтправлено = Ложь;
	//КоличествоПопыток = 0;
	//Пока НЕ ПисьмоОтправлено И КоличествоПопыток < 3 Цикл
	//	
	//	КоличествоПопыток = КоличествоПопыток + 1;
	//	Попытка
	//		РаботаСПочтовымиСообщениями.ОтправитьПочтовоеСообщение(СистемнаяУчетнаяЗапись, ПараметрыПисьма);			
	//		ПисьмоОтправлено = Истина;
	//	Исключение
	//		ЗаписьЖурналаРегистрации(
	//			"Ошибка отправки E-mail",
	//			УровеньЖурналаРегистрации.Ошибка,
	//			Метаданные.Документы.EMails,
	//			Object,
	//			ОписаниеОшибки());
	//	КонецПопытки;
	//		
	//КонецЦикла;

	//Если НЕ ПисьмоОтправлено Тогда
	//	ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
	//		"Failed to send e-mail!
	//		|" + ОписаниеОшибки(),
	//		ЭтотОбъект, , , Отказ);
	//КонецЕсли;
	
КонецПроцедуры




