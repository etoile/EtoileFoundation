#ifdef __cplusplus
#import <Foundation/NSEnumerator.h>

extern "C" void objc_enumerationMutation(id);
namespace etoile
{
/**
 * ETFastEnumerationIterator is a C++ iterator that can be used with any
 * Objective-C class that implements fast enumeration.  It is responsible for
 * fetching the objects in an Objective-C collection.
 */
class ETFastEnumerationIterator
{
	bool isEnd;
	int i;
	int count;
	__unsafe_unretained id buffer[16];
	NSFastEnumerationState state;
	__unsafe_unretained id<NSFastEnumeration> obj;
	long mutated;
public:
	ETFastEnumerationIterator(id<NSFastEnumeration> object, bool end=false)
		: isEnd(false), i(0), count(0), state({0}), obj(object)
	{
		if (end)
		{
			isEnd = true;
			return;
		}
		count = [obj countByEnumeratingWithState: &state objects: buffer count: 16];
		mutated = *state.mutationsPtr;
	}
	id operator*() const
	{
		if (*state.mutationsPtr != mutated)
		{
			objc_enumerationMutation(obj);
		}
		return state.itemsPtr[i];
	}
	const ETFastEnumerationIterator& operator++()
	{
		i++;
		if (i >= count)
		{
			count = [obj countByEnumeratingWithState: &state objects: buffer count: 16];
			i = 0;
		}
		return *this;
	}
	bool operator!=(const ETFastEnumerationIterator &e)
	{
		if (e.isEnd)
		{
			return !((e.obj == obj) && (count == 0));
		}
		return true;
	}
};
}
/**
 * An adaptor function that allows Objective-C collections that implement
 * NSFastEnumeration to be used with C++ iterator-expecting templates.
 */
etoile::ETFastEnumerationIterator begin(id<NSFastEnumeration>obj)
{
	return etoile::ETFastEnumerationIterator(obj);
}

/**
 * An adaptor function that allows Objective-C collections that implement
 * NSFastEnumeration to be used with C++ iterator-expecting templates.
 */
etoile::ETFastEnumerationIterator end(id<NSFastEnumeration>obj)
{
	return etoile::ETFastEnumerationIterator(obj, true);
}

#endif
