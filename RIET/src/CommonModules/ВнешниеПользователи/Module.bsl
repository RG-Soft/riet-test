////////////////////////////////////////////////////////////////////////////////
// Подсистема "Пользователи".
//
////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Возвращает признак использования внешних пользователей в программе
// (значение функциональной опции ИспользоватьВнешнихПользователей).
//
// Возвращаемое значение:
//  Булево - если Истина, внешние пользователи включены.
//
Функция ИспользоватьВнешнихПользователей() Экспорт
	
	Возврат ПолучитьФункциональнуюОпцию("ИспользоватьВнешнихПользователей");
	
КонецФункции

// См. одноименную функцию в общем модуле ПользователиКлиентСервер.
Функция ТекущийВнешнийПользователь() Экспорт
	
	Возврат ПользователиКлиентСервер.ТекущийВнешнийПользователь();
	
КонецФункции

// Возвращает ссылку на объект авторизации внешнего пользователя, полученный из информационной базы.
// Объект авторизации - это ссылка на объект информационной базы, используемый
// для связи с внешним пользователем, например, контрагент, физическое лицо и т.д.
//
// Параметры:
//  ВнешнийПользователь - Неопределено - используется текущий внешний пользователь.
//                      - СправочникСсылка.ВнешниеПользователи - указанный внешний пользователь.
//
// Возвращаемое значение:
//  Ссылка - объект авторизации одного из типов, указанных в описании типов в свойстве.
//           "Метаданные.Справочники.ВнешниеПользователи.Реквизиты.ОбъектыАвторизации.Тип".
//
Функция ПолучитьОбъектАвторизацииВнешнегоПользователя(ВнешнийПользователь = Неопределено) Экспорт
	
	Если ВнешнийПользователь = Неопределено Тогда
		ВнешнийПользователь = ПользователиКлиентСервер.ТекущийВнешнийПользователь();
	КонецЕсли;
	
	ОбъектАвторизации = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(ВнешнийПользователь, "ОбъектАвторизации").ОбъектАвторизации;
	
	Если ЗначениеЗаполнено(ОбъектАвторизации) Тогда
		Если ПользователиСлужебный.ОбъектАвторизацииИспользуется(ОбъектАвторизации, ВнешнийПользователь) Тогда
			ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				ВернутьСтр("ru = 'Ошибка в базе данных:
				           |Объект авторизации ""%1"" (%2)
				           |установлен для нескольких внешних пользователей.'"),
				ОбъектАвторизации,
				ТипЗнч(ОбъектАвторизации));
		КонецЕсли;
	Иначе
		ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			ВернутьСтр("ru = 'Ошибка в базе данных:
			           |Для внешнего пользователя ""%1"" не задан объект авторизации.'"),
			ВнешнийПользователь);
	КонецЕсли;
	
	Возврат ОбъектАвторизации;
	
КонецФункции

// Используется для настройки отображения наличия внешних пользователей в списках справочников (партнеры, респонденты и др.) 
// являющихся объектом авторизации в справочнике ВнешниеПользователи.
//
// Параметры:
//  Форма - УправляемаяФорма - вызывающий объект.
//
Процедура НастроитьОтображениеСпискаВнешнихПользователей(Форма) Экспорт
	
	Если ПравоДоступа("Чтение", Метаданные.Справочники.ВнешниеПользователи) Тогда
		Возврат;
	КонецЕсли;
	
	// Удаление отображения недоступных сведений.
	СхемаЗапроса = Новый СхемаЗапроса;
	СхемаЗапроса.УстановитьТекстЗапроса(Форма.Список.ТекстЗапроса);
	Источники = СхемаЗапроса.ПакетЗапросов[0].Операторы[0].Источники;
	Для Индекс = 0 По Источники.Количество() - 1 Цикл
		Если Источники[Индекс].Источник.ИмяТаблицы = "Справочник.ВнешниеПользователи" Тогда
			Источники.Удалить(Индекс);
		КонецЕсли;
	КонецЦикла;
	Форма.Список.ТекстЗапроса = СхемаЗапроса.ПолучитьТекстЗапроса();
	
КонецПроцедуры


#КонецОбласти
