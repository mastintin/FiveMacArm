#ifndef STDSIZE_H
#define STDSIZE_H
#include <cstddef>
namespace std {
template <class T, size_t N> constexpr size_t size(const T (&)[N]) noexcept {
  return N;
}
} // namespace std
#endif
