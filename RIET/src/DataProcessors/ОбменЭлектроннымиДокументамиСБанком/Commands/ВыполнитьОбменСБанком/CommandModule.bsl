
&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	
	ОчиститьСообщения();
	ПараметрыСихронизации = Новый Структура;
	МассивНастроекЭДО = Новый Массив;
	МассивНастроекЭДО.Добавить(ПараметрыВыполненияКоманды.Источник.Объект.НастройкаЭДО);
	ПараметрыСихронизации.Вставить("НастройкиЭДОСБанками", МассивНастроекЭДО);
	ПараметрыСихронизации.Вставить("ТекущийИндексСинхронизацииСБанками", 0);
	
	ЭлектронныеДокументыСлужебныйКлиент.ВыполнитьОбменСБанками(Неопределено, ПараметрыСихронизации);
	
КонецПроцедуры
