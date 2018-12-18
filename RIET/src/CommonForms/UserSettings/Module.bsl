
////////////////////////////////////////////////////////////////////////////////
// СОБЫТИЯ ФОРМЫ

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	// Пропускаем инициализацию, чтобы гарантировать получение формы при передаче параметра "АвтоТест".
	Если Параметры.Свойство("АвтоТест") Тогда
		Возврат;
	КонецЕсли;
	
	ВыполнитьПроверкуПравДоступа("СохранениеДанныхПользователя", Метаданные);
	
КонецПроцедуры 


////////////////////////////////////////////////////////////////////////////////
// СОБЫТИЯ ЭЛЕМЕНТОВ УПРАВЛЕНИЯ

&НаКлиенте
Процедура ЗаписатьИЗакрыть(Команда)
	
	МассивСтруктур = Новый Массив;
	
	ОбщегоНазначения.ХранилищеОбщихНастроекСохранитьМассивИОбновитьПовторноИспользуемыеЗначения(МассивСтруктур);
	
	Закрыть();
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьРасширениеРаботыСФайламиНаКлиенте(Команда)
	
	УстановитьРасширениеРаботыСФайлами();
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьПараметрыСистемы(Команда)
	
	ОбновитьПовторноИспользуемыеЗначения();
	ОбновитьИнтерфейс();
	
	ПоказатьОповещениеПользователя(,,"Параметры системы были успешно обновлены");
	
КонецПроцедуры