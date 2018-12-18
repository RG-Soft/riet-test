#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ЭтаФорма.ТолькоПросмотр = ПолучитьФункциональнуюОпцию("РаботаВАвтономномРежиме");
	
	МожноРедактировать = ПравоДоступа("Редактирование", Метаданные.Справочники.ОбщероссийскийКлассификаторОсновныхФондов);
	Элементы.СписокКонтекстноеМенюИзменитьВыделенные.Видимость = МожноРедактировать И НЕ ЭтаФорма.ТолькоПросмотр;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ИзменитьВыделенные(Команда)

	ГрупповоеИзменениеОбъектовКлиент.ИзменитьВыделенные(Элементы.Список);

КонецПроцедуры

#КонецОбласти