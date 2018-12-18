////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ - ОБРАБОТЧИКИ СОБЫТИЙ ПОЛЕЙ ТАБЛИЦЫ СПИСОК

&НаКлиенте
Процедура СписокПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа)
	
	Если Копирование Тогда
		Возврат;
	КонецЕсли;
	
	Отказ = Истина;
	
	Если СпособОбменаЭД = ПредопределенноеЗначение("Перечисление.СпособыОбменаЭД.ЧерезВебРесурсБанка") Тогда
		ОткрытьФорму("Справочник.СоглашенияОбИспользованииЭД.Форма.ФормаЭлементаБанк",
					 ,
					 ,
					 УникальныйИдентификатор);
	Иначе
		ОткрытьФорму("Справочник.СоглашенияОбИспользованииЭД.ФормаОбъекта",
					 ,
					 ,
					 УникальныйИдентификатор);
	КонецЕсли;
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ - ОБРАБОТЧИКИ СОБЫТИЙ ФОРМЫ

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("РежимОткрытияОкна") Тогда
		ЭтотОбъект.РежимОткрытияОкна = Параметры.РежимОткрытияОкна;
	КонецЕсли;
	
	Элементы.Контрагент.Видимость = (НЕ ЭтотОбъект.Параметры.Отбор = Неопределено
									 И ЭтотОбъект.Параметры.Отбор.Свойство("СпособОбменаЭД", СпособОбменаЭД))
									И СпособОбменаЭД = Перечисления.СпособыОбменаЭД.ЧерезВебРесурсБанка;
	
КонецПроцедуры
